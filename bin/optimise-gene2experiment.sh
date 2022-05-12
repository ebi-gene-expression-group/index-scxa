#!/usr/bin/env bash
SCHEMA_VERSION=1

# On developers environment export SOLR_HOST and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"scxa-gene2experiment-v$SCHEMA_VERSION"}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

# creates a new file descriptor 3 that redirects to 1 (STDOUT)
exec 3>&1

echo "Optimising $COLLECTION..."
HTTP_STATUS=$(curl $SOLR_AUTH -w "%{http_code}" -o >(cat >&3) -s "http://${HOST}/solr/${COLLECTION}/update?optimize=true")

if [[ ! $HTTP_STATUS == 2* ]]; then
   # HTTP Status is not a 2xx code
   echo "Faiure on optimising collection $coll"
   exit 1
fi