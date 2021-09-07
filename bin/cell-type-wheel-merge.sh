#!/usr/bin/env bash

# Add properties from object in $2 whose key matches the field cell_id in $1
jq -c \
--slurpfile ctw $2 \
'
. + $ctw[0][.cell_id]
' $1

