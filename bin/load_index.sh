#!/usr/bin/env bash
export SCHEMA_VERSION=1
export SOLR_COLLECTION=scxa-analytics-v$SCHEMA_VERSION

echo "Loading cond. sdrf $CONDENSED_SDRF_TSV into host $SOLR_HOST collection $SOLR_COLLECTION..."

condSdrf2tsvForSCXAJSONFactorsIndex.sh $CONDENSED_SDRF_TSV | jsonGroupByCellID.sh | loadJSONIndexToSolr.sh
