#!/usr/bin/env bash

echo "["
awk -F'\t' 'BEGIN { OFS = "\t"; } { if( $4 == "factor" || $4 == "characteristic" ) { gsub(/ /, "_", $5); print "{ \"experiment_accession\": \""$1"\",\n \"cell_id\": \""$3"\",\n \""$4"_"$5"\": [\""$6"\"],\n \""$4"s\": [\""$5"\"]},"; } }' $1
echo "{}]"
