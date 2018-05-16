#!/usr/bin/env bash
set -e

[ -z ${CONDENSED_SDRF_TSV+x} ] && echo "CONDENSED_SDRF_TSV env var is needed." && exit 1

export SCHEMA_VERSION=2
export SOLR_COLLECTION=scxa-analytics-v$SCHEMA_VERSION

echo "Loading cond. sdrf $CONDENSED_SDRF_TSV into host $SOLR_HOST collection $SOLR_COLLECTION..."

condSdrf2tsvForSCXAJSONFactorsIndex.sh $CONDENSED_SDRF_TSV | jsonGroupByCellID.sh | loadJSONIndexToSolr.sh
