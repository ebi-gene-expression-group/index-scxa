#!/usr/bin/env bash
set -e

[ -z ${MATRIX_MARKT_ROWS_GENES_FILE+x} ] && echo "MATRIX_MARKT_ROWS_GENES_FILE env var is needed." && exit 1
[ -f ${MATRIX_MARKT_ROWS_GENES_FILE} ] || ( echo "MATRIX_MARKT_ROWS_GENES_FILE pointing to $MATRIX_MARKT_ROWS_GENES_FILE is not a file or does not exist." && exit 1 )
[ -z ${EXP_ID+x} ] && echo "EXP_ID env var is needed." && exit 1

cleanup() {
  echo "Cleaning up JSONL file"
  rm $MATRIX_MARKT_ROWS_GENES_JSONL_FILENAME
}
trap cleanup exit


export SCHEMA_VERSION=1
export SOLR_COLLECTION=scxa-gene2experiment
export SOLR_PROCESSORS=${SOLR_COLLECTION}-v${SCHEMA_VERSION}_dedup

MATRIX_MARKT_ROWS_GENES_JSONL_FILENAME=`basename $MATRIX_MARKT_ROWS_GENES_FILE`.jsonl
echo "Transform $MATRIX_MARKT_ROWS_GENES_FILE to JSONL -> $MATRIX_MARKT_ROWS_GENES_JSONL_FILENAME"
matrixMarktGenes2json.sh > $MATRIX_MARKT_ROWS_GENES_JSONL_FILENAME

export INPUT_JSONL=$MATRIX_MARKT_ROWS_GENES_JSONL_FILENAME
solr-jsonl-chunk-loader.sh
