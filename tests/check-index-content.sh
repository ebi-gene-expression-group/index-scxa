#!/usr/bin/env bash
SCHEMA_VERSION=2

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"scxa-analytics-v$SCHEMA_VERSION"}

# This is the dependant of the example file.
# We will query for organism_part and disease for cell_id SRR6257788
org_part=$(grep 'SRR6257788' $CONDENSED_SDRF_TSV | grep 'organism part' | awk -F'\t' '{ print $6 }')
disease=$(grep 'SRR6257788' $CONDENSED_SDRF_TSV | grep 'disease' | awk -F'\t' '{ print $6 }')

echo '[{ "characteristic_organism_part": ["'$org_part'"], "characteristic_disease": ["'$disease'"]}]' > expected.json

curl "http://$HOST/solr/$CORE/select?fl=characteristic_organism_part,characteristic_disease&q=cell_id:%22SRR6257788%22" | \
  jq '.response.docs' > result.json

# Compare expected and resulting json
cmp <(jq -cS . result.json) <(jq -cS . expected.json)
