#!/usr/bin/env bash

set -e

awk -v EXP_ID="$EXP_ID" \
    '{ print "{ \"experiment_accession\": \""EXP_ID"\",\n \"bioentity_identifier\": \""$2"\" }" }' \
       $MATRIX_MARKT_ROWS_GENES_FILE
