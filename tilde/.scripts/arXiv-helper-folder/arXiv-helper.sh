#!/bin/bash

## Dependencies: internet connection, exiftool, wget

## TODO
## 1. Too many globle variables.. very dangerous!
## 2. Is breaking the functions into several little subfunctions a good practice? If yes, do it.

AddIdentifier() {

	# ------------------------------------------------------------------------------------ #
	#
	#  Input : 1905.03531.pdf
	#  This program adds "arXiv:1905.03531.pdf" to the file identifier.
	#
	#  Input : q-alg--9602027.pdf
	#  This program adds "arXiv:q-alg/9602027" to the file identifier.
	#
	#  Input : q-alg--9602027v1.pdf
	#  This program adds "arXiv:q-alg/9602027v1" to the file identifier.

	#  For more information about the arXiv identifier, please
	#  refer to the official site
	# 	 Understanding the arXiv identifier (https://arxiv.org/help/arxiv_identifier)
	#  To check if the file identifier is added, use the command
	# 	 $ exiftool filename.pdf -identifier
	#
	# ------------------------------------------------------------------------------------ #
	InputFile=$1
	ArXivId=$(echo $InputFile | sed 's/.pdf//' | sed 's/--/\//' )
	exiftool "$InputFile" -identifier="arXiv:$ArXivId" # Adding file identifier.

}

AddMetaData() {

	# ------------------------------------------------------------------------------------ #
	#
	#  Input file must have identifier in the form:
	# 	 arXiv:[archive].[subject-class]/YYMM[number]{vV}
	#  	 arXiv:YYMM.number{vV}
	#  For example 	arXiv:math.GT/0309136	or
	# 		arXiv:1501.00001	or
	# 		arXiv:0706.0001v2	.
	#  For more information about arXiv identifier, please refer to the official site:
	#  	Understanding the arXiv identifier (https://arxiv.org/help/arxiv_identifier)
	#  To check the identifier of the file, enter the command
	#  	$ exiftool TheFileName.pdf -Identifier
	#
	# ------------------------------------------------------------------------------------ #

	InputFile=$1
	# Read the file identifier
	Identifier=$(exiftool $InputFile -identifier | sed 's/Identifier *: //')

	# Analyze the identifier and get the corresponding metadata from export.arxiv.org
	case $Identifier in # TODO: the regex is not good. fix it!
		"arXiv:"*"/"*)
			IdentifierType="Prior2007" ;;
		"arXiv:"*"."*)
			IdentifierType="After2007" ;;
		*)
			echo "ERROR: Not an arXiv identifier.. exit 1."
			exit 1 ;;
	esac
	ArXivIdentifierAvoidingSlash=$(echo "$Identifier" | sed 's/\//--/' ) # Change '/' to '--' in those of Type-Prior2007.
	ArXivIdentifierWithoutVersion=$(echo "$Identifier" | sed 's/arXiv://' | sed 's/v[0-9]*//' ) # TODO: check if this regex is correct
	ArXivMetaDataSiteURL="http://export.arxiv.org/oai2?verb=GetRecord&metadataPrefix=arXivRaw&identifier=oai:arXiv.org:$ArXivIdentifierWithoutVersion"
	TempMetaDataFileName="tmp.$ArXivIdentifierAvoidingSlash.xml"
	wget -O "$TempMetaDataFileName" "$ArXivMetaDataSiteURL" # Fetch metadata from the URL and output as an .xml file.
	MetaContent=$(echo $(<"$TempMetaDataFileName") | sed 's/\n//g') # The newlines are cut-off.

	# Extract things we want from the downloaded metadata file.
	VersionInfo=$(	echo $MetaContent | \
			sed 	-e '/version/ !d' -e 's/<\/version>/<\/version>\n/g' |
			sed	-e '/version/ !d' \
				-e 's/.*<ver/<ver/' \
				-e 's/<ver.*="//' \
				-e 's/"><date>/: /' \
				-e 's/<\/date>.*// ' \
				-e 's/.*/(&)/' \
	)
	Title=$(echo $MetaContent | sed 's/.*<title>//' | sed 's/<\/title>.*//')
	Authors=$(echo $MetaContent | sed 's/.*<authors>//' | sed 's/<\/authors>.*//')
	Categories="arXiv: $(echo $MetaContent | sed 's/.*<categories>//' | sed 's/<\/categories>.*//')"
	Abstract=$(echo $MetaContent | sed 's/.*<abstract>//' | sed 's/<\/abstract>.*//' | sed "s/^[ \t]*//" )
	case $MetaContent in ## Check if d.o.i. exists.
		*"<doi>"*"</doi>"*)
			DoiExist="true"
			Doi=$(echo $MetaContent | sed 's/.*<doi>//' | sed 's/<\/doi>.*//') ;;
		*)
			DoiExist="false"
			Doi="unknown" ;;
	esac

	# Change metadata of our .pdf files with 'exiftool'.
	echo -e "Changing metadata of the file...\n"
	exiftool $InputFile -title="$Title" -author="$Authors" -categories="$Categories" -doi="$Doi" -description="[$Identifier] [Abstract] $Abstract [VersionInfo] $VersionInfo"
	echo -e "\nMetadata changed! Use '$ exiftool FileName.pdf' to check new metadata."

	# Rename the file and remove the temporary file.
	NewFileName=$(echo "$Title-[$Authors]-[$ArXivIdentifierAvoidingSlash].pdf")
	cp "$InputFile" "$NewFileName" 		# renaming the files.
	mv "$InputFile""_original" "$InputFile" # recovering the unprocessed files.
	rm -rf $TempMetaDataFileName		# removing the temporary files.

	# Report
	echo -e "\n====== Report ======"
	echo -e "  ArXivIdentifier = $Identifier"
	echo -e "  IdentifierType = $IdentifierType"
	echo -e "  VersionInfo = $VersionInfo"
	echo -e "  Title = $Title"
	echo -e "  Authors = $Authors"
	echo -e "  Categories = $Categories"
	echo -e "  DoiExist = $DoiExist"
	echo -e "  Doi = $Doi"
	echo	"  Abstract = $Abstract"

}

main() {
	# One and only one of the following two modes must be executed each time.
	FileIdentifierAddingMode="OFF"
	MetaDataAddingMode="OFF"
	case "$1" in
		"-i") FileIdentifierAddingMode="ON" ;;
		"-m") MetaDataAddingMode="ON" ;;
		"-im"|"-mi") MetaDataAddingMode="ON" ; FileIdentifierAddingMode="ON" ;;
		*) echo "ERROR: the first argument is either -i or -m. exit 1." ; exit 1 ;;
	esac

	shift ;
	InputArray=("$@")
	LackMode="True"
	for object in "${InputArray[@]}"; do
		if [[ $FileIdentifierAddingMode == "ON" ]]; then
			echo "FileIdentifierAddingMode is on"
			AddIdentifier "$object"
			LackMode="False"
		fi

		if [[ $MetaDataAddingMode == "ON" ]]; then
			echo "MetaDataAddingMode is on."
			AddMetaData "$object"
			LackMode="False"
		fi

		if [[ $LackMode == "True" ]]; then
			echo "Please specify a mode.. exit 1." ; exit 1 ;
		fi
	done
}

main "$@" ;

exit
