scriptname=$(realpath "$0")
rootdir="$(dirname "$scriptname")"
inputdir="$rootdir/sessions"
outputdir="$rootdir/web"
style="${2-sessionnotes}"

for mdfile in "$inputdir"/*.md; do

    # mdfile="$1"
    # htmlfile="$1.html"
    basefile="$(basename "$mdfile")"
    htmlfile="$outputdir/$basefile.html"

    if [ ! -f "$mdfile" ]; then
        # specified markdown file doesn't exist --------------------
        echo "Markdown document ( $mdfile ) isn't a usable file."

    else
        # everything seems fine ------------------------------------
        echo "using the $style style on $mdfile ..."

        cat "$rootdir/html/generic/preall.html" > "$htmlfile"
        cat "$rootdir/html/styles/pre$style.html" >> "$htmlfile"
        marked -i "$mdfile" >> "$htmlfile"
        cat "$rootdir/html/generic/postall.html" >> "$htmlfile"

        echo "...created file:///`wslpath -m "$htmlfile"` "

    fi

done # finished for loop though md files in ./sessions
