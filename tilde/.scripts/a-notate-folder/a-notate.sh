#!/bin/bash
#INSTALL@ /usr/local/bin/a-notate

## Originally written by ljmdullaart (Github), introducing me to 'hashing'.

my_editor=${EDITOR:-vim}
my_file_manager=${FILE:-ranger}
maindir=$HOME/.a-notate
logfile="$maindir/.log.tsv"
tmpfile=$(mktemp)

# Initialize
[ ! -d "$maindir" ] 		&& (mkdir -p "$maindir" ; cd "$maindir" ; git init)
[ ! -f "$maindir/overview" ] 	&& touch "$maindir/overview"

# Read the path of file
if [ -z "$1" ] ; then
	echo "yes, but which file should I annotate?"
	exit
else
	file2do="$(realpath "$1")"
	[[ -f "$file2do" ]] || { echo "Annotation only works for files but not directory.. exit 1" ; exit 1; }
	echo "file2do=$file2do"
fi

# Compute the hash of the file
checksum=$(md5sum -b "$file2do" | sed 's/ .*//')

# Make a directory for that hash, open it, and create a soft link to the chosen file
[ -d "$maindir/$checksum" ] || mkdir "$maindir/$checksum"
filename=$(echo $file2do | sed 's/.*\///')
ln -sf "$file2do" "$maindir/$checksum/$(date -Is)--$filename"
$my_file_manager "$maindir/$checksum" # TODO: how to open ranger in another window?

# Determine state: both/ifchecksum/iffile2do/neither
cat "$maindir/overview" | awk -v FS="\t" -v checksum="$checksum" '$1==checksum {print $2}' > "$tmpfile"
[[ -s "$tmpfile" ]] && ifchecksum=true || ifchecksum=false
if $ifchecksum ; then
	grep -qFw "$file2do" "$tmpfile" && iffile2do=true || iffile2do=false
else
	cat "$maindir/overview" | awk -v FS="\t" -v file2do="$file2do" '$2==file2do {print $1}' > "$tmpfile"
	[[ -s "$tmpfile" ]] && iffile2do=true || iffile2do=false
fi
echo ifchecksum=$ifchecksum iffile2do=$iffile2do

# Action based on state: both/ifchecksum/iffile2do/neither
if $ifchecksum && $iffile2do ; then
	echo "opened the annotation from location: $file2do at $(date -Is)">>"$maindir/$checksum/.history"
	$my_editor "$maindir/$checksum/index.md"
elif $ifchecksum  ; then
	oldfile=$(head -1 $tmpfile)
	echo "Hmmm.. this looks like $oldfile"
	echo "Did you move or copy that file?"
	echo "enter to edit the original notes, control-c to abort"
	read line
	grep -v "$oldfile" "$maindir/overview" > $tmpfile
	mv $tmpfile "$maindir/overview"
	echo -e "$checksum\t$file2do">>"$maindir/overview"
	echo "opened the annotation from location: $file2do at $(date -Is)">>"$maindir/$checksum/.history"
	$my_editor "$maindir/$checksum/index.md"
elif $iffile2do ; then
	echo "Hmmm.. Seems like the file $file2do has changed"
	oldcksum=$(head -1 $tmpfile)
	cp -r "$maindir/$oldcksum/." "$maindir/$checksum"
	echo "--moved from and older hash:$oldcksum to here:$checksum at $(date -Is)">>"$maindir/$checksum/.history"
	echo "Copied $oldcksum to $checksum"
	grep -v "$oldcksum" "$maindir/overview" > "$tmpfile"
	mv "$tmpfile" "$maindir/overview"
	echo -e "$checksum\t$file2do">>"$maindir/overview"
	$my_editor "$maindir/$checksum/index.md"
else
	echo "New file $file2do ($checksum)"
	echo -e "$checksum\t$file2do">>"$maindir/overview"
	echo "# $file2do">>"$maindir/$checksum/index.md"
	echo "opened the annotation from location: $file2do at $(date -Is)">>"$maindir/$checksum/.history"
	$my_editor "$maindir/$checksum/index.md"
fi

# Finalize: log and version control
echo -e "$(date -Is)\t$(hostname)\t$(whoami)\t$file2do\t$checksum" >> "$logfile"
cd "$maindir" ; git init ; git add . ; git commit -m "a change at $(date -Is)"

exit
