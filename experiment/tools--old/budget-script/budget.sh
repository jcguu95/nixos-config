#!/bin/bash
# Thie budget analyzer reads a budget file($1) and asks for the time scope to be analyzed.

ReadOptions() {
	# read the options
	TEMP=`getopt -o d::g::t:a: --long detail::,generate::,threshold:,append: -- "$@"`
	## options followed by ":" need arguments, whereas options followed by "::" do not necessarily need arguments.
	## For more information, find https://www.tutorialspoint.com/unix_commands/getopt.html
	## TODO: Add 'filter'.
	eval set -- "$TEMP" # TODO ??What exactly does this do??

	# extract options and their arguments into variables.
	DetailMode="off"
	DetailCategory="ALL"
	ColumnToAppend="NONE"
	Threshold=0
	GenMode="off"
	### Filter="NONE" # TODO: Add 'filter'
	while true ; do
		case "$1" in
			-d|--detail)
				DetailMode="on" ;
				case "$2" in
					"") DetailCategory="ALL" ; shift 2 ;;
					*)  DetailCategory="$2"  ; shift 2 ;;
				esac ;;
			-g|--generate)
				if [[ $2 != "" ]]; then
					echo "ERROR: GenMode is either on or off."
					exit 1 ;
				fi
				GenMode="on"; shift 2 ;;
			-t|--threshold)
				Threshold=$2 ; shift 2 ;; # Threshold against absolute value
			-a|--append)
				ColumnToAppend=$2 ; shift 2 ;;
			--) shift ; break ;;
			*) echo "Internal error!" ; exit 1 ;;
		esac
	done

	# Now take action
	echo -e "\nAnalyzing \"$INPUT_FILE\" with the following options:\n"
	echo -e "\tDetailMode     (d) = $DetailMode"
	echo -e "\tDetailCategory     = $DetailCategory"
	echo -e "\tGenMode        (g) = $GenMode"
	echo -e "\tThreshold      (f) = $Threshold"
	echo -e "\tColumnToAppend (a) = $ColumnToAppend ... TODO!"
	echo ""
}

Analyze() {
	# Read time span
	read -p "Reading initial date            : " INIT_DATE
	INIT_DATE=$(date -d "$INIT_DATE" +"%Y-%m-%d")
	read -p "Reading end date (or time span) : " END_DATE
	case $END_DATE in
		+*)	END_DATE=$(date -d "$INIT_DATE $END_DATE" +"%Y-%m-%d")
			;;
		*)	END_DATE=$(date -d "$END_DATE" +"%Y-%m-%d")
			;;
	esac
	# Finish reading time span

	echo -e "\nAnalyzing from $INIT_DATE to $END_DATE...\n"

	rm -rf tmp.*.csv # TODO: How to make sure all such files will always be deleted?
	awk -f sort-budget.awk FS="," InitDate=$INIT_DATE EndDate=$END_DATE InputFile=$INPUT_FILE $INPUT_FILE; # Call an outside program sort-budget.awk ! FS means file seperator. # Notice that this will generate temporary files..

	echo ""
}

main() {
	INPUT_FILE=$1 ; shift ;
	ReadOptions $@ ; # A function given above
	Analyze ;	 # Another function given above

	# DetailMode --- If in detail mode, print out the sorted details as standard output.
	# TODO: Detail mode should affect the temporary files! This makes the GenMode easier.
	case $DetailMode in
		"on")
			echo -e "# Detail mode is on; details are provided below with options (DetailCategory=$DetailCategory) (Threshold=$Threshold).\n" ;
			awk -v FS="," -v threshold="$Threshold" '($3*$3)>=(threshold*threshold) {print $0}' tmp.*.$DetailCategory.*.csv | sort -t, -nk3 ;
			# No abs() defined in AWK.
			# I don't know if the command "sort" can handle this by itself. Namely, can sort sorts with condition?
			# TODO: with nonzero threshold, the current program does not re-calculate the TOTAL (first row) in detail mode!
			;;
		"off")
			echo "# Detail mode is off; no details are provided."	;;
	esac

	# GenMode --- Keep the temporary files if generating mode is on; otherwise, remove them.
	# TODO: GenMode should respect detail mode ! For example, if DetailCategory is set to "F", only the 'F' temporary file should be kept.
	case $GenMode in
		"on")
			echo -e "# Generating mode is on; the temporary files are not removed.\n" ;;
		"off")
			echo -e "# Generating mode is off; cleaning the temporary files ...\n" ;;
	esac

	exit ;
}

main $@ ; # Remember that in shell script functions can change global variables!

exit
