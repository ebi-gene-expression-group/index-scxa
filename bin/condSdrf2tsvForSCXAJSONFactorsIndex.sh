#!/usr/bin/env bash

echo "["
awk -F'\t' 'BEGIN { OFS = "\t"; } { if( $4 == "factor" ) { gsub(/ /, "_", $5); print "{ \"experiment_accession\": \""$1"\",\n \"cell_id\": \""$3"\",\n \"factor_"$5"\": \""$6"\"},"; } }' $1
echo "{}]"
