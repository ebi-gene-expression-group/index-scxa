#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. ${DIR}/../bin/scxa-analytics-schema-version.env

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"scxa-analytics-v$SCHEMA_VERSION"}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

echo "Retrieving fields in the schema"
curl $SOLR_AUTH "http://$HOST/solr/$CORE/schema?wt=json" \
  | jq '.schema.fields + .schema.dynamicFields | .[].name ' | sed s/\"//g \
  | sort > loaded_fields.txt

echo "Parsing creation script"
grep -A 2 '\("add-field"\|"add-dynamic-field"\)' "$(dirname "${BASH_SOURCE[0]}")"/../bin/create-scxa-analytics-schema.sh \
  | grep '"name"' | awk -F':' '{ print $2 }' | sed 's/[\", ]//g' \
  | sort > expected_loaded_fields.txt

echo "Running comm"
comm -13 loaded_fields.txt expected_loaded_fields.txt
