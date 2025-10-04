scriptname=$(realpath "$0")
rootdir="$(dirname "$scriptname")"
sessiondir="$rootdir/strahdsessions"
pagesdir="$rootdir/html/pages"
outputdir="$rootdir/docs"
indexfile="$outputdir/index.html"
datafile="$outputdir/pages.json"
style="${2-sessionnotes}"

bullet='\u25b6'

function declare {
    # tell the user something
    node -e "process.stdout.write('$1')"
}

declare "\n\u2756\u2756 Site Compiler \u2756\u2756\n\n"

wslmode=false
if command -v wslpath; then
    wslmode=true
fi
declare "$bullet WSL mode set to $wslmode \n"

# get the index started
cat "$rootdir/html/generic/preall.html" > "$indexfile"
cat "$rootdir/html/styles/preindex.html" >> "$indexfile"

# get the data file started
echo "{ \"pages\": [" > "$datafile"

# loop through all the plain ol' pages
declare "$bullet copying plain pages: "
for pagefile in "$pagesdir"/*.html; do

    declare "."
    pagefilename="$(basename "$pagefile")"
    pageoutput="$outputdir/$pagefilename"
    cp "$pagefile" "$pageoutput"
    declare "\u2713"

done # finished for loop though pages files
declare " done\n"


# loop through all the session md files in the input dir
declare "$bullet style is set to: $style \n"
declare "$bullet compiling session files: "
for mdfile in "$sessiondir"/*.md; do

    declare "."
    basefile="$(basename "$mdfile")"
    htmlfilename="$basefile.html"
    htmlfile="$outputdir/$htmlfilename"

    if [ ! -f "$mdfile" ]; then
        # specified markdown file doesn't exist --------------------
        declare "Markdown document ( $mdfile ) isn't a usable file.\n"

    else
        # everything seems fine ------------------------------------

        ## concatenate all the pieces
        cat "$rootdir/html/generic/preall.html" > "$htmlfile"
        declare "."
        cat "$rootdir/html/styles/pre$style.html" >> "$htmlfile"
        declare "."
        marked -i "$mdfile" >> "$htmlfile"
        declare "."
        cat "$rootdir/html/styles/post$style.html" >> "$htmlfile"
        declare "."
        cat "$rootdir/html/generic/postall.html" >> "$htmlfile"
        declare "."

        # also add this to the list of sessions
        echo "<li><a href=\"$htmlfilename\">$htmlfilename</a></li>" >> "$indexfile"
        declare "."

        # also add this to the list of pages for scanning stuff
        echo "    \"$htmlfilename\"," >> "$datafile"
        declare "."
        declare "\u2713"

    fi
done # finished for loop though md files in the session dir
declare " done\n"

# finish the data file
echo "    \"\"" >> "$datafile"
echo "]}" >> "$datafile"

# finish the index
cat "$rootdir/html/styles/postindex.html" >> "$indexfile"
cat "$rootdir/html/generic/postall.html" >> "$indexfile"

if $wslmode; then
    declare "\nIndex is at:" "\n"
    declare "    file:///`wslpath -m "$indexfile"` "
else
    declare "\nIndex is at:" "\n"
    declare "    file:///$indexfile "
fi
