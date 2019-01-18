#!/usr/bin/env bash
set -e
SCHEMA_VERSION=3

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"scxa-analytics-v$SCHEMA_VERSION"}

# This is the dependant of the example file.
# We will query for organism_part and cell_id SRR6257788
characteristic="organism_part"
cell_id="SRR6257788"

org_part=$(grep $cell_id $CONDENSED_SDRF_TSV | grep 'organism part' | awk -F'\t' '{ print $6 }')

# BioSolr seems to do the ontology expansion on the background and not blocking
# the loading call. As such, we need to wait during testing to make sure that
# elements have been loaded
pings=0
numRecordsLoaded=0
while [ "$numRecordsLoaded" -eq 0 ]; do
  if [ "$pings" -gt 50 ]; then
    echo "Timed out waiting for load after $pings tries."
    exit 1
  fi
  sleep 20
  numRecordsLoaded=$(curl -s "http://$HOST/solr/$CORE/select?fl=characteristic_name,characteristic_value&q=cell_id:$cell_id%20AND%20characteristic_name:$characteristic" | jq '.response.numFound')
  ((++pings))
done
echo "Pings: $pings"


echo '[{ "characteristic_name": ["'$characteristic'"], "characteristic_value": ["'$org_part'"]}]' > expected.json

curl "http://$HOST/solr/$CORE/select?fl=characteristic_name,characteristic_value&q=cell_id:$cell_id%20AND%20characteristic_name:$characteristic" | \
jq '.response.docs' > result.json

# Compare expected and resulting json
cmp <(jq -cS . result.json) <(jq -cS . expected.json)
