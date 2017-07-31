#!/bin/bash
FILES=$(find ./tests -name "*.swift" -o -name "*.html")
#xdelta3 -A -e -n -s $@
for FILE in $FILES
do
        BASE=$(basename "$FILE")
	DIR=$(dirname "$FILE")
	NAME="${BASE%.[^.]*}"
	OUT="$DIR/$NAME.bin"
	echo "$DIR to $OUT"
	xdelta3 -S -A -f -e -n -s /dev/null "$FILE" "$OUT"
done
