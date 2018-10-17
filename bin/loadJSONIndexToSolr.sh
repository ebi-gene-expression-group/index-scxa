#!/usr/bin/env bash

export HOST=${SOLR_HOST:-$1}
export COLLECTION=${SOLR_COLLECTION:-$2}

echo $HOST
echo $COLLECTION

if [ ! -z ${PROCESSOR+x} ]; then
  PROCESSOR="&processor="$PROCESSOR
fi

curl "http://$HOST/solr/$COLLECTION/update?commit=true$PROCESSOR" --data-binary @- -H 'Content-type:application/json'
