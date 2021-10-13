#!/usr/bin/env bash
set -e

[ -z ${CONDENSED_SDRF_TSV+x} ] && echo "CONDENSED_SDRF_TSV env var is needed." && exit 1

cleanup() {
  echo "Cleaning up all JSON/JSONL files"
  #rm $COND_SDRF_JSONL_FILENAME $CTW_HELPER_JSON_FILENAME $CTW_ENRICHED_COND_SDRF_JSONL_FILENAME
}
trap cleanup exit

export WORKDIR=${WORKDIR:-`pwd`}

export SCHEMA_VERSION=6
export SOLR_COLLECTION=scxa-analytics
export SOLR_PROCESSORS=${SOLR_COLLECTION}-v${SCHEMA_VERSION}_dedupe,${SOLR_COLLECTION}-v${SCHEMA_VERSION}_ontology_expansion

BASE_FILENAME=`basename $CONDENSED_SDRF_TSV .tsv`

COND_SDRF_JSONL_FILENAME=$WORKDIR/$BASE_FILENAME.jsonl
echo "Transform condensed SDRF file to JSONL -> $COND_SDRF_JSONL_FILENAME"
condSdrf2tsvForSCXAJSONFactorsIndex.sh $CONDENSED_SDRF_TSV | jq -c '.' > $COND_SDRF_JSONL_FILENAME

CTW_HELPER_JSON_FILENAME=$WORKDIR/$BASE_FILENAME.cell-type-wheel.json
echo "Creating cell type wheel helper dictionary JSON file -> $CTW_HELPER_JSON_FILENAME"
cell-type-wheel-cond-sdrf-to-ctw-fields.sh $COND_SDRF_JSONL_FILENAME > $CTW_HELPER_JSON_FILENAME

CTW_ENRICHED_COND_SDRF_JSONL_FILENAME=$WORKDIR/$BASE_FILENAME.ctw-enriched.jsonl
echo "Adding cell type wheel fields to create final JSONL file -> $CTW_ENRICHED_COND_SDRF_JSONL_FILENAME"
cell-type-wheel-merge.sh $COND_SDRF_JSONL_FILENAME $CTW_HELPER_JSON_FILENAME | jsonl-filter-empty-string-values.sh > $CTW_ENRICHED_COND_SDRF_JSONL_FILENAME

export INPUT_JSONL=$CTW_ENRICHED_COND_SDRF_JSONL_FILENAME
solr-jsonl-chunk-loader.sh

