#!/usr/bin/env bash

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

curl -X POST -H 'Content-type:application/json' --data-binary '{
  "set-user-property": {"update.autoCreateFields":false}
}' $SOLR_AUTH "http://$HOST/solr/$CORE/config"
