#!/usr/bin/env bash
SCHEMA_VERSION=3
set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"scxa-analytics-v$SCHEMA_VERSION"}

# This is the dependant of the example file.
# We will query for organism_part and cell_id SRR6257788
characteristic="organism_part"
cell_id="SRR6257788"

org_part=$(grep $cell_id $CONDENSED_SDRF_TSV | grep 'organism part' | awk -F'\t' '{ print $6 }')

echo '[{ "characteristic_name": ["'$characteristic'"], "characteristic_value": ["'$org_part'"]}]' > expected.json

curl "http://$HOST/solr/$CORE/select?fl=characteristic_name,characteristic_value&q=cell_id:$cell_id%20AND%20characteristic_name:$characteristic" | \
jq '.response.docs' > result.json

# Compare expected and resulting json
cmp <(jq -cS . result.json) <(jq -cS . expected.json)