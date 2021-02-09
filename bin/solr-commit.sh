#!/usr/bin/env bash

OUTPUT=${SOLR_COMMIT_OUTPUT:-"/dev/null"}

HTTP_STATUS=$(
curl -X POST \
     -H 'Content-Type: application/json' \
     --data-binary '{ "commit": {} }' \
     -s -o ${OUTPUT}  -w "%{http_code}" \
     "http://${SOLR_HOST}/solr/${SOLR_COLLECTION}/update")

if [[ ! $HTTP_STATUS == 2* ]];
then
  echo "Commit operation failed with HTTP status $HTTP_STATUS"
  exit 1
fi

exit 0
