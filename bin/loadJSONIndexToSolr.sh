#!/usr/bin/env bash

export HOST=${SOLR_HOST:-$1}
export COLLECTION=${SOLR_COLLECTION:-$2}

echo $HOST
echo $COLLECTION

if [ $PROCESSOR ] && [ $ONTOLOGY_PROCESSOR ]; then
	PROCESSOR="?processor="$PROCESSOR","$ONTOLOGY_PROCESSOR
elif [ $PROCESSOR ]; then 
	PROCESSOR="?processor="$PROCESSOR
elif [ $ONTOLOGY_PROCESSOR ]; then
	PROCESSOR="?processor="$ONTOLOGY_PROCESSOR
fi

#creates a new file descriptor 3 that redirects to 1 (STDOUT)
exec 3>&1
# Run curl in a separate command, capturing output of -w "%{http_code}" into HTTP_STATUS
# and sending the content to this command's STDOUT with -o >(cat >&3)
HTTP_STATUS=$(curl -w "%{http_code}" -o >(cat >&3) "http://$HOST/solr/$COLLECTION/update$PROCESSOR" --data-binary @- -H 'Content-type:application/json')

if [[ ! $HTTP_STATUS == 2* ]];
then
	 # HTTP Status is not a 2xx code, so it is an error.
   exit 1
fi
