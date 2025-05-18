scriptname=$(realpath "$0")
rootdir="$(dirname "$scriptname")"
sessiondir="$rootdir/strahdsessions"
pagesdir="$rootdir/html/pages"
outputdir="$rootdir/docs"
indexfile="$outputdir/index.html"
datafile="$outputdir/pages.json"
style="${2-sessionnotes}"

bullet="\u25b6"

echo -e "\n\u2756\u2756 Site Compiler \u2756\u2756\n"

wslmode=false
echo -ne "$bullet wslpath is: "
if command -v wslpath; then
    wslmode=true
fi
echo -e "$bullet WSL mode set to" $wslmode

# get the index started
cat "$rootdir/html/generic/preall.html" > "$indexfile"
cat "$rootdir/html/styles/preindex.html" >> "$indexfile"

# get the data file started
echo "{ \"pages\": [" > "$datafile"

# loop through all the plain ol' pages
echo -ne "$bullet copying plain pages: "
for pagefile in "$pagesdir"/*.html; do

    echo -ne "."
    pagefilename="$(basename "$pagefile")"
    pageoutput="$outputdir/$pagefilename"
    cp "$pagefile" "$pageoutput"
    echo -ne "\u2713"

done # finished for loop though pages files
echo " done"


# loop through all the session md files in the input dir
echo -e "$bullet style is set to: $style "
echo -ne "$bullet compiling session files: "
for mdfile in "$sessiondir"/*.md; do

    echo -n "."
    basefile="$(basename "$mdfile")"
    htmlfilename="$basefile.html"
    htmlfile="$outputdir/$htmlfilename"

    if [ ! -f "$mdfile" ]; then
        # specified markdown file doesn't exist --------------------
        echo "Markdown document ( $mdfile ) isn't a usable file."

    else
        # everything seems fine ------------------------------------

        ## concatenate all the pieces
        cat "$rootdir/html/generic/preall.html" > "$htmlfile"
        echo -n "."
        cat "$rootdir/html/styles/pre$style.html" >> "$htmlfile"
        echo -n "."
        marked -i "$mdfile" >> "$htmlfile"
        echo -n "."
        cat "$rootdir/html/styles/post$style.html" >> "$htmlfile"
        echo -n "."
        cat "$rootdir/html/generic/postall.html" >> "$htmlfile"
        echo -n "."

        # also add this to the list of sessions
        echo "<li><a href=\"$htmlfilename\">$htmlfilename</a></li>" >> "$indexfile"
        echo -n "."

        # also add this to the list of pages for scanning stuff
        echo "    \"$htmlfilename\"," >> "$datafile"
        echo -n "."
        echo -ne "\u2713"

    fi
done # finished for loop though md files in the session dir
echo " done"

# finish the data file
echo "    \"\"" >> "$datafile"
echo "]}" >> "$datafile"

# finish the index
cat "$rootdir/html/styles/postindex.html" >> "$indexfile"
cat "$rootdir/html/generic/postall.html" >> "$indexfile"

if $wslmode; then
    echo -e "\nIndex is at:"
    echo "    file:///`wslpath -m "$indexfile"` "
else
    echo -e "\nIndex is at:"
    echo "    file:///$indexfile "
fi
