#!/usr/bin/env bash
SCHEMA_VERSION=1

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"scxa-ontology-v$SCHEMA_VERSION"}
NUMSHARDS=${SOLR_NUM_SHARD:-1}
REPLICATES=${SOLR_NUM_REPL:-1}

printf "\n\nCreating collection $CORE based on $HOST"
curl "http://$HOST/solr/admin/collections?action=CREATE&name=$CORE&numShards=$NUMSHARDS&replicationFactor=$REPLICATES"
