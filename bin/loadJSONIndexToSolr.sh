#!/usr/bin/env bash

export HOST=${SOLR_HOST:-$1}
export COLLECTION=${SOLR_COLLECTION:-$2}

echo $HOST
echo $COLLECTION

curl "http://$HOST/solr/$COLLECTION/update?commit=true" --data-binary @- -H 'Content-type:application/json'
