#!/usr/bin/env bash
set -e

[ -z ${CONDENSED_SDRF_TSV+x} ] && echo "CONDENSED_SDRF_TSV env var is needed." && exit 1

export SCHEMA_VERSION=4
export SOLR_COLLECTION=scxa-analytics-v$SCHEMA_VERSION
export PROCESSOR=$SOLR_COLLECTION\_dedup
export ONTOLOGY_PROCESSOR=$SOLR_COLLECTION\_ontology_expansion

echo "Loading cond. sdrf $CONDENSED_SDRF_TSV into host $SOLR_HOST collection $SOLR_COLLECTION..."

CHUNK_PREFIX=${CHUNK_PREFIX:-"cond-sdrf-chunk-"}
NUM_DOCS_PER_BATCH=${NUM_DOCS_PER_BATCH:-100000}
split -a 3 -l $NUM_DOCS_PER_BATCH $CONDENSED_SDRF_TSV $CHUNK_PREFIX
CHUNK_FILES=`ls $CHUNK_PREFIX*`

I=O
for CHUNK_FILE in $CHUNK_FILES
do
  I=$(($I + 1)) 
  echo "$CHUNK_FILE ${I}/`wc -w <<< $CHUNK_FILES`"
  condSdrf2tsvForSCXAJSONFactorsIndex.sh $CHUNK_FILE | jsonFilterEmptyFields.sh | loadJSONIndexToSolr.sh
  STATUS=$?
  [ $STATUS -ne 0 ] && break
done
rm $CHUNK_FILES
exit $STATUS
