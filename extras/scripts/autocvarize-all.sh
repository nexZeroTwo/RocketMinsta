#!/usr/bin/env bash

autocvarize="$(dirname "$0")/autocvarize.pl"
cd "$(dirname "$0")"/../..

function handle {
    find qcsrc/"$1" \( -type f -a \( -name \*.c -o -name \*.qc -o -name \*.h -o -name \*.qh \) \) -print0 | xargs -0 perl "$autocvarize" > qcsrc/"$1"/_autocvars.qh
    mv qcsrc/"$1"/_autocvars.qh qcsrc/"$1"/autocvars.qh
}

handle server
handle client
handle menu
