#!/usr/bin/env bash
SCHEMA_VERSION=1

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"scxa-gene2experiment-v$SCHEMA_VERSION"}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

expected_entries=$(wc $MATRIX_MARKT_ROWS_GENES_FILE | awk '{ print $1 }')
entries=$(curl $SOLR_AUTH "http://$HOST/solr/$CORE/select?&q=experiment_accession:%22MyExp%22" | jq .response.numFound)

# Compare expected and resulting json
[ "$expected_entries" = "$entries" ] && echo "Found expected number of entries"
