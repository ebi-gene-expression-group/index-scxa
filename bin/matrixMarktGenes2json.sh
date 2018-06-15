#!/usr/bin/env bash

awk -v EXP_ID="$EXP_ID" \
    '{ print "{ \"experiment_accession\": \""EXP_ID"\",\n \"gene_id\": \""$2"\" }" }' \
       $MATRIX_MARKT_ROWS_GENES_FILE | jq -s
