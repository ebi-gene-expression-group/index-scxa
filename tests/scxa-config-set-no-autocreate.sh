#!/usr/bin/env bash

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION}

curl -X POST -H 'Content-type:application/json' --data-binary '{
  "set-user-property": {"update.autoCreateFields":"false"}
}' "http://$HOST/solr/$CORE/config"
