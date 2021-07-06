#!/usr/bin/env bash

# Merges an object in $2 to an object in $1 if they have the same value in  the
# field cell_id

jq \
--slurpfile ctw $1 \
'
# Merge entries from the matched object in array $ctw
# The first element [0] is hard-coded since we expect only a single match
. as {cell_id: $cell_id} |
. + ($ctw | map(select(.cell_id == $cell_id))[0])
' $2
