#!/usr/bin/env bash

awk -F'\t' 'BEGIN { OFS = "\t"; } { if( $4 == "factor" || $4 == "characteristic" ) { gsub(/ /, "_", $5); print "{ \"experiment_accession\": \""$1"\", \"cell_id\": \""$3"\", \""$4"_name\": \""$5"\", \""$4"_value\": \""$6"\", \"ontology_annotation\": \""$7"\" }"; } }' $1
