#!/usr/bin/env bash
SCHEMA_VERSION=2

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"scxa-analytics-v$SCHEMA_VERSION"}

echo "Retrieving fields in the schema"
curl http://$HOST/solr/$CORE/schema?wt=json \
  | jq '.schema.fields + .schema.dynamicFields | .[].name ' | sed s/\"//g \
  | grep -v '^\*' | grep -v '^_' | grep -v '^id$' | grep -v '^attr_\*$' \
  | sort > loaded_fields.txt

echo "Parsing creationg script"
ls -l bin/create-scxa-analytics-schema.sh
grep -A 2 '\("add-field"\|"add-dynamic-field"\)' bin/create-scxa-analytics-schema.sh \
  | grep '"name"' | awk -F':' '{ print $2 }' | sed 's/[\", ]//g' \
  | sort > expected_loaded_fields.txt

echo "Expected"
cat expected_loaded_fields.txt
echo "Actual"
cat loaded_fields.txt
echo "Running cmp"
cmp loaded_fields.txt expected_loaded_fields.txt
echo "Done"
