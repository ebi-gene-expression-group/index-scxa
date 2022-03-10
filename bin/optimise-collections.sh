#!/usr/bin/env bash
ANALYTICS_SCHEMA_VERSION=6
GENE2EXP_SCHEMA_VERSION=1

# On developers environment export SOLR_HOST and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
ANALYTICS_COLLECTION=${SOLR_COLLECTION:-"scxa-analytics-v$ANALYTICS_SCHEMA_VERSION"}
GENE2EXP_COLLECTION=${SOLR_COLLECTION:-"scxa-gene2experiment-v$GENE2EXP_SCHEMA_VERSION"}

echo "Optimising analytics..."
# creates a new file descriptor 3 that redirects to 1 (STDOUT)
exec 3>&1

status=0
for coll in $ANALYTICS_COLLECTION $GENE2EXP_COLLECTION; do
   HTTP_STATUS=$(curl -w "%{http_code}" -o >(cat >&3) -s "http://${HOST}/solr/${coll}/update?optimize=true")

   if [[ ! $HTTP_STATUS == 2* ]];
   then
      # HTTP Status is not a 2xx code
      echo "Faiure on optimising collection $coll"
      status=1
   fi
done

exit $status