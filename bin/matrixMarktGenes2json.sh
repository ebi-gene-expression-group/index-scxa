#!/usr/bin/env bash

awk -v EXP_ID="$EXP_ID" \
    '{ print "{ \"experiment_accession\": \""EXP_ID"\",\n \"bioentity_identifier\": \""$2"\" }" }' \
       $MATRIX_MARKT_ROWS_GENES_FILE | jq -s .
