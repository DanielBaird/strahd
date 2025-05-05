scriptname=$(realpath "$0")
rootdir="$(dirname "$scriptname")"
sessiondir="$rootdir/sessions"
pagesdir="$rootdir/html/pages"
outputdir="$rootdir/docs"
indexfile="$outputdir/index.html"
datafile="$outputdir/pages.json"
style="${2-sessionnotes}"

# get the index started
cat "$rootdir/html/generic/preall.html" > "$indexfile"
cat "$rootdir/html/styles/preindex.html" >> "$indexfile"

# get the data file started
echo "{ \"pages\": [" > "$datafile"

# loop through all the plain ol' pages
for pagefile in "$pagesdir"/*.html; do

    echo "copying $pagefile ..."
    pagefilename="$(basename "$pagefile")"
    pageoutput="$outputdir/$pagefilename"
    cp "$pagefile" "$pageoutput"

done # finished for loop though pages files


# loop through all the session md files in the input dir
for mdfile in "$sessiondir"/*.md; do

    basefile="$(basename "$mdfile")"
    htmlfilename="$basefile.html"
    htmlfile="$outputdir/$htmlfilename"

    if [ ! -f "$mdfile" ]; then
        # specified markdown file doesn't exist --------------------
        echo "Markdown document ( $mdfile ) isn't a usable file."

    else
        # everything seems fine ------------------------------------
        echo "using the $style style on $basefile ..."

        ## co0ncatenate all the pieces
        cat "$rootdir/html/generic/preall.html" > "$htmlfile"
        cat "$rootdir/html/styles/pre$style.html" >> "$htmlfile"
        marked -i "$mdfile" >> "$htmlfile"
        cat "$rootdir/html/styles/post$style.html" >> "$htmlfile"
        cat "$rootdir/html/generic/postall.html" >> "$htmlfile"

        # also add this to the list of sessions
        echo "<li><a href=\"$htmlfilename\">$htmlfilename</a></li>" >> "$indexfile"

        # also add this to the list of pages for scanning stuff
        echo "    \"$htmlfilename\"," >> "$datafile"

        if command -v wslpath; then
            echo "    ...created $htmlfilename at file:///`wslpath -m "$htmlfile"` "
        else
            echo "    ...created $htmlfilename at file:///$htmlfile "
        fi
    fi
done # finished for loop though md files in ./sessions

# finish the data file
echo "    \"\"" >> "$datafile"
echo "]}" >> "$datafile"

# finish the index
cat "$rootdir/html/styles/postindex.html" >> "$indexfile"
cat "$rootdir/html/generic/postall.html" >> "$indexfile"
