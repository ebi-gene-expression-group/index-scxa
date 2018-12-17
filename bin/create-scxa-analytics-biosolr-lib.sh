#!/usr/bin/env bash
SCHEMA_VERSION=3

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"scxa-analytics-v$SCHEMA_VERSION"}
BIOSOLR_JAR_PATH="${BIOSOLR_JAR_PATH:-${PWD}/../lib/solr-ontology-update-processor-1.1.jar}"

# There is no need to create the .system collection, it is automatically created by Solr when we set the size property.
printf "\n\nIncreasing blob size limit on blob store collection."
curl "http://$HOST/solr/.system/config" -H 'Content-type:application/json' -d '{"set-user-property" : {"blob.max.size.mb":"20"}}'

printf "\n\nAdding BioSolr jar to blob store."
curl -X POST -H 'Content-Type: application/octet-stream' --data-binary @${BIOSOLR_JAR_PATH} "http://$HOST/solr/.system/blob/biosolr"

printf "\n\nAdd runtime lib to collection classpath."
curl "http://$HOST/api/collections/$CORE/config" -H 'Content-type:application/json' -d '{"add-runtimelib": {"name":"biosolr","version":1}}'