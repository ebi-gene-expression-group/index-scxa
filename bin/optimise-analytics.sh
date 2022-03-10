#!/usr/bin/env bash
SCHEMA_VERSION=6

# On developers environment export SOLR_HOST and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"scxa-analytics-v$ANALYTICS_SCHEMA_VERSION"}

# creates a new file descriptor 3 that redirects to 1 (STDOUT)
exec 3>&1

echo "Optimising $COLLECTION..."
HTTP_STATUS=$(curl -w "%{http_code}" -o >(cat >&3) -s "http://${HOST}/solr/${coll}/update?optimize=true")

if [[ ! $HTTP_STATUS == 2* ]]; then
   # HTTP Status is not a 2xx code
   echo "Faiure on optimising collection $coll"
   exit 1
fi