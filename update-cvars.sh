#!/bin/bash

TARGET="."
if [ "x$1" != "x" ]; then
	TARGET="$1"
fi
TARGET="$(readlink -m "$TARGET")"

if [ -d "$TARGET" ]; then
	echo " --- Entering $TARGET --- "
	ls "$TARGET" | while read line; do
		$0 "$TARGET/$line"
	done
	exit 0
fi

echo "ALTERING: $TARGET"
./cvars.sed "$TARGET" > "$TARGET.tmp" && mv "$TARGET.tmp" "$TARGET"
