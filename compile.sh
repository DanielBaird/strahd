scriptname=$(realpath "$0")
rootdir="$(dirname "$scriptname")"
inputdir="$rootdir/sessions"
outputdir="$rootdir/docs"
indexfile="$outputdir/index.html"
style="${2-sessionnotes}"

# get the index started
cat "$rootdir/html/generic/preall.html" > "$indexfile"
cat "$rootdir/html/styles/preindex.html" >> "$indexfile"

for mdfile in "$inputdir"/*.md; do

    # mdfile="$1"
    # htmlfile="$1.html"
    basefile="$(basename "$mdfile")"
    htmlfilename="$basefile.html"
    htmlfile="$outputdir/$htmlfilename"

    if [ ! -f "$mdfile" ]; then
        # specified markdown file doesn't exist --------------------
        echo "Markdown document ( $mdfile ) isn't a usable file."

    else
        # everything seems fine ------------------------------------
        echo "using the $style style on $basefile ..."

        cat "$rootdir/html/generic/preall.html" > "$htmlfile"
        cat "$rootdir/html/styles/pre$style.html" >> "$htmlfile"
        marked -i "$mdfile" >> "$htmlfile"
        cat "$rootdir/html/styles/post$style.html" >> "$htmlfile"
        cat "$rootdir/html/generic/postall.html" >> "$htmlfile"

        echo "<li><a href=\"$htmlfilename\">$htmlfilename</a></li>" >> "$indexfile"

        if command -v wshpath; then
            echo "...created $htmlfilename at file:///`wslpath -m "$htmlfile"` "
        else
            echo "...created $htmlfilename at file:///$htmlfile "
        fi

    fi

done # finished for loop though md files in ./sessions

# finish the index
cat "$rootdir/html/styles/postindex.html" >> "$indexfile"
cat "$rootdir/html/generic/postall.html" >> "$indexfile"
