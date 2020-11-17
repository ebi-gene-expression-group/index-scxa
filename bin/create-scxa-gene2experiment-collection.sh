#!/usr/bin/env bash
SCHEMA_VERSION=1

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"scxa-gene2experiment-v$SCHEMA_VERSION"}
NUM_SHARDS=${SOLR_NUM_SHARDS:-1}
REPLICATES=${SOLR_REPLICATES:-1}
MAX_SHARDS_PER_NODE=${SOLR_MAX_SHARDS_PER_NODE:-1}

printf "\n\nCreating collection $CORE based on $HOST"
curl "http://$HOST/solr/admin/collections?action=CREATE&name=$CORE&collection.configName=$CORE&numShards=$NUM_SHARDS&replicationFactor=$REPLICATES&maxShardsPerNode=$MAX_SHARDS_PER_NODE"
