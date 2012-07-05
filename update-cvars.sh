#!/bin/bash

if [ "x$1" != "x" ]; then
	TARGET="$1"
else
	cat <<EOF
Usage: $0 targetfile

Upgrades references to RM cvars in targetfile, which may be either a single file or a directory, in which case all files withing that directory will be converted recursively.
EOF
	exit 1
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
