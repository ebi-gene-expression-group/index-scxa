#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. ${DIR}/../bin/scxa-analytics-schema-version.env

HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"scxa-analytics-v${SCHEMA_VERSION}"}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

REQUEST_URI="http://$HOST/solr/$COLLECTION/suggest?suggest=true"
BUILD=${BUILD_SUGGESTERS:-true}

SUGGESTERS="ontologyAnnotationSuggester ontologyAnnotationAncestorSuggester ontologyAnnotationParentSuggester ontologyAnnotationSynonymSuggester"

FAILS=$SUGGESTERS
TEST_QUERY=blood
MAX_TRIES=5
COUNTER=0

while [ -n "$FAILS" ] && [ "$COUNTER" -lt "$MAX_TRIES" ]; do

    newFails=''

    # A successful suggester is one that returns a status code of 0, and a
    # number of results greater than 0 for the test query. Testing indicates
    # that still-building suggesters provide a return code of 500.

    for SUGGESTER in $SUGGESTERS; do
        RESPONSE=$(curl $SOLR_AUTH -X GET "$REQUEST_URI&suggest.dictionary=$SUGGESTER&suggest.q=$TEST_QUERY" 2> /dev/null)
        RESPONSE=$(echo -e "$RESPONSE" | tr -d '\n' | sed 's/\t/ /g')

        STATUS_CODE=$(echo -e "$RESPONSE" | jq '.responseHeader.status')
        NUM_FOUND=$(echo -e "$RESPONSE" | jq ".suggest.${SUGGESTER}.${TEST_QUERY}.numFound")

        if [ "$STATUS_CODE" -eq '0' ]; then
            echo "$SUGGESTER built and producing status 0"
            if [ "$NUM_FOUND" -eq '0' ]; then
                echo "Warning: $SUGGESTER produced no results for $TEST_QUERY" 1>&2
            fi
        else
            echo "Error: $SUGGESTER build failed, status code $STATUS_CODE" 1>&2
            newFails="$newFails $SUGGESTER"
        fi
    done

    # If we have fails, give it 5 mins and try again (up to $MAX_TRIES tries)

    COUNTER=$((COUNTER+1))
    if [ -n "$newFails" ]; then
        if [ "$COUNTER" -lt "$MAX_TRIES" ]; then
            echo "This was try $COUNTER. Sleeping for 5 mins before a retry (max tries $MAX_TRIES)" 1>&2
            sleep 5m
        else
            echo "Maximumum number of retries exceeded" 1>&2
        fi
    fi

    # Just remove any leading spaces from FAILS
    FAILS=$(echo -e "$newFails" | sed 's/^ //')

done

if [ -n "$FAILS" ]; then
    echo "Some suggesters failed: $FAILS" 1>&2
    exit 1
else
    echo "All suggesters succeeded"
fi
