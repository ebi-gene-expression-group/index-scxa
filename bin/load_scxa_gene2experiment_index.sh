#!/usr/bin/env bash
set -e

[ -z ${MATRIX_MARKT_ROWS_GENES_FILE+x} ] && echo "MATRIX_MARKT_ROWS_GENES_FILE env var is needed." && exit 1
[ -z ${EXP_ID+x} ] && echo "EXP_ID env var is needed." && exit 1


export SCHEMA_VERSION=1
export SOLR_COLLECTION=scxa-gene2experiment-v$SCHEMA_VERSION
export PROCESSOR=$SOLR_COLLECTION\_dedup

echo "Loading genes from $MATRIX_MARKT_ROWS_GENES_FILE into host $SOLR_HOST collection $SOLR_COLLECTION..."

matrixMarktGenes2json.sh | loadJSONIndexToSolr.sh
