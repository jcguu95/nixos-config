# Taken from the post
#
# "What's the most robust way to efficiently parse CSV using awk?
# https://stackoverflow.com/questions/45420535/whats-the-most-robust-way-to-efficiently-parse-csv-using-awk
#
# , this awk scripts parse simple csv.

function buildRec(      i,orig,fpat,done) {
    $0 = PrevSeg $0
    if ( gsub(/"/,"&") % 2 ) {
        PrevSeg = $0 RS
        done = 0
    }
    else {
        PrevSeg = ""
        gsub(/@/,"@A"); gsub(/""/,"@B")            # <"x@foo""bar"> -> <"x@Afoo@Bbar">
        orig = $0; $0 = ""                         # Save $0 and empty it
        fpat = "([^" FS "]*)|(\"[^\"]+\")"         # Mimic GNU awk FPAT meaning
        while ( (orig!="") && match(orig,fpat) ) { # Find the next string matching fpat
            $(++i) = substr(orig,RSTART,RLENGTH)   # Create a field in new $0
            gsub(/@B/,"\"",$i); gsub(/@A/,"@",$i)  # <"x@Afoo@Bbar"> -> <"x@foo"bar">
            gsub(/^"|"$/,"",$i)                    # <"x@foo"bar">   -> <x@foo"bar>
            orig = substr(orig,RSTART+RLENGTH+1)   # Move past fpat+sep in orig $0
        }
        done = 1
    }
    return done
}

BEGIN { FS=OFS="," }
!buildRec() { next }
{
    printf "Record %d:\n", ++recNr
    for (i=1;i<=NF;i++) {
        # To replace newlines with blanks add gsub(/\n/," ",$i) here
        printf "    $%d=<%s>\n", i, $i
    }
    print "----"
}
