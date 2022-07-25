#!/usr/bin/env bash
SCHEMA_VERSION=1

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"scxa-gene2experiment-v$SCHEMA_VERSION"}
NUM_SHARDS=${SOLR_NUM_SHARDS:-1}
REPLICATES=${SOLR_REPLICATES:-1}
MAX_SHARDS_PER_NODE=${SOLR_MAX_SHARDS_PER_NODE:-1}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

printf "\n\nDeleting alias for collection\n"
curl $SOLR_AUTH "http://${HOST}/solr/admin/collections?action=DELETEALIAS&name=scxa-gene2experiment"

printf "\n\nDeleting collection ${COLLECTION} based on ${HOST}\n"
curl $SOLR_AUTH "http://${HOST}/solr/admin/collections?action=DELETE&name=${COLLECTION}"

printf "\n\nCreating collection $CORE based on $HOST"
curl $SOLR_AUTH "http://$HOST/solr/admin/collections?action=CREATE&name=$COLLECTION&collection.configName=$COLLECTION&numShards=$NUM_SHARDS&replicationFactor=$REPLICATES&maxShardsPerNode=$MAX_SHARDS_PER_NODE"

printf "\n\nCreating collection ${COLLECTION} alias scxa-gene2experiment\n"
curl $SOLR_AUTH "http://${HOST}/solr/admin/collections?action=CREATEALIAS&name=scxa-gene2experiment&collections=${COLLECTION}"
