#!/usr/bin/env bash
SCHEMA_VERSION=${SCHEMA_VERSION:-3}

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"scxa-analytics-v$SCHEMA_VERSION"}


curl -X POST -H 'Content-type:application/json' --data-binary '{
  "set-user-property": {"update.autoCreateFields":"false"}
}' http://$HOST/solr/$CORE/config
