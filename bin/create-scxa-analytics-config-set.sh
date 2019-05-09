#!/usr/bin/env bash
SCHEMA_VERSION=3

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"scxa-analytics-v$SCHEMA_VERSION"}
BASE=${SOLR_BASE_CONFIG:-"_default"}

printf "\n\nCreating config based on $BASE for our collection."
curl "http://$HOST/solr/admin/configs?action=CREATE&name=$CORE&baseConfigSet=$BASE"

# Set this value to whatever is needed, it doesn’t really much with current Lucene versions
# https://issues.apache.org/jira/browse/SOLR-4586
MAX_BOOLEAN_CLAUSES=16384
printf "\n\nRaising value of maxBooleanClauses to $MAX_BOOLEAN_CLAUSES."
curl "http://$HOST/solr/$CORE/config" -H 'Content-type:application/json' -d "
{
  "set-property": {
    "query.maxBooleanClauses" : ${MAX_BOOLEAN_CLAUSES}
  }
}"
