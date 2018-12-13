#!/usr/bin/env bash

export HOST=${SOLR_HOST:-$1}
export COLLECTION=${SOLR_COLLECTION:-$2}

echo $HOST
echo $COLLECTION

if [ $PROCESSOR ] && [ $ONTOLOGY_PROCESSOR ]; then
	PROCESSOR="&processor="$PROCESSOR","$ONTOLOGY_PROCESSOR
elif [ $PROCESSOR ]; then 
	PROCESSOR="&processor="$PROCESSOR
elif [ $ONTOLOGY_PROCESSOR ]; then
	PROCESSOR="&processor="$ONTOLOGY_PROCESSOR
fi

curl "http://$HOST/solr/$COLLECTION/update?commit=true$PROCESSOR" --data-binary @- -H 'Content-type:application/json'
