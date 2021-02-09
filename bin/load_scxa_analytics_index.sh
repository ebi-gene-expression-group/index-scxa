#!/usr/bin/env bash
set -e

[ -z ${CONDENSED_SDRF_TSV+x} ] && echo "CONDENSED_SDRF_TSV env var is needed." && exit 1

export SCHEMA_VERSION=5
export SOLR_COLLECTION=scxa-analytics-v$SCHEMA_VERSION
export PROCESSOR=$SOLR_COLLECTION\_dedup
export ONTOLOGY_PROCESSOR=$SOLR_COLLECTION\_ontology_expansion

echo "Loading cond. sdrf $CONDENSED_SDRF_TSV into host $SOLR_HOST collection $SOLR_COLLECTION..."

CHUNK_PREFIX=${CHUNK_PREFIX:-"cond-sdrf-chunk-"}
NUM_DOCS_PER_BATCH=${NUM_DOCS_PER_BATCH:-100000}
split -a 3 -l $NUM_DOCS_PER_BATCH $CONDENSED_SDRF_TSV $CHUNK_PREFIX
CHUNK_FILES=$(ls $CHUNK_PREFIX*)

I=O
set +e
for CHUNK_FILE in $CHUNK_FILES
do
  I=$(($I + 1)) 
  echo "$CHUNK_FILE ${I}/$(wc -w <<< $CHUNK_FILES)"
  condSdrf2tsvForSCXAJSONFactorsIndex.sh $CHUNK_FILE | jsonFilterEmptyFields.sh | loadJSONIndexToSolr.sh
  STATUS=$?
  [ $STATUS -ne 0 ] && break
done
set -e
rm $CHUNK_FILES

HTTP_STATUS=$(curl -X POST -H 'Content-Type: application/json' \
"http://$SOLR_HOST/solr/$SOLR_COLLECTION/update" --data-binary \
'{ "commit": {} }')

if [[ ! $HTTP_STATUS == 2* ]];
then
   echo "Commit operation failed with HTTP status $HTTP_STATUS"
   exit 1
fi

exit $STATUS
