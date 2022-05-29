#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. ${DIR}/../scxa-analytics-schema-version.env

#This below long curl request build suggestions on the solr server for the mentioned dictionaries as part of http request
#Once build request completes, user can search for the suggestions
# To search for the suggestions, here is the curl request:
# curl -X GET 'http://localhost:8983/solr/scxa-analytics-v5/suggest?suggest=true&suggest.dictionary=ontologyAnnotationSuggester&suggest.dictionary=ontologyAnnotationAncestorSuggester&suggest.dictionary=ontologyAnnotationParentSuggester&suggest.dictionary=ontologyAnnotationSynonymSuggester&suggest.dictionary=ontologyAnnotationChildSuggester&suggest.q=skin'

# on developers environment export SOLR_HOST and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"scxa-analytics-v${SCHEMA_VERSION}"}

REQUEST_URI="http://$HOST/solr/$COLLECTION/suggest?suggest=true"
BUILD=${BUILD_SUGGESTERS:-true}
REQUIRE_TEST_RESULTS=${REQUIRE_TEST_RESULTS:-false}

# Build suggesters one by one

suggesters="ontologyAnnotationSuggester ontologyAnnotationAncestorSuggester ontologyAnnotationParentSuggester ontologyAnnotationSynonymSuggester ontologyAnnotationChildSuggester"

if [ "$BUILD" = true ] ; then
    for suggester in $suggesters; do 

        echo "Building $suggester"    
        
        # For some reason the error trace that can come back invalidates the
        # json so we need some 'tr' and 'sed' magic
        
        response=$(curl "$REQUEST_URI&suggest.build=true&suggest.dictionary=$suggester")
        response=$(echo -e "$response" | tr -d '\n' | sed 's/\t/ /g')
        statusCode=$(echo -e "$response" | jq '.responseHeader.status')
        
        if [ "$statusCode" -eq '0' ]; then
            echo "Successfully built suggester: $suggester"
        else
            echo -e "Failed to build suggester $suggester, response was: \n\n$response\n" 1>&2
        fi
    done
fi

# Verify zero status and valid response in all suggesters

fails=$suggesters
testQuery=blood
maxTries=5
counter=0

while [ -n "$fails" ] && [ "$counter" -lt "$maxTries" ]; do

    newFails=''

    # A successful suggester is one that returns a status code of 0, and a
    # number of results greater than 0 for the test query. Testing indicates
    # that still-building suggesters provide a return code of 500.

    for suggester in $suggesters; do
        response=$(curl -X GET "$REQUEST_URI&suggest.dictionary=$suggester&suggest.q=$testQuery" 2> /dev/null)
        response=$(echo -e "$response" | tr -d '\n' | sed 's/\t/ /g')

        statusCode=$(echo -e "$response" | jq '.responseHeader.status')
        numFound=$(echo -e "$response" | jq ".suggest.${suggester}.${testQuery}.numFound")

        if [ "$statusCode" -eq '0' ]; then
            echo "$suggester built and producing status 0"
            if [ "$numFound" -eq '0' ]; then
                echo "Warning: $suggester produced no results for $testQuery" 1>&2
                if [ "$REQUIRE_TEST_RESULTS" = true ] ; then
                    newFails="$newFails $suggester"    
                fi
            fi
        else
            echo "Error: $suggester build failed, status code $statusCode" 1>&2
            newFails="$newFails $suggester"
        fi
    done

    # If we have fails, give it 5 mins and try again (up to $maxTries tries) 

    counter=$((counter+1))
    if [ -n "$newFails" ]; then
        if [ "$counter" -lt "$maxTries" ]; then
            echo "This was try $counter. Still have failing suggesters, sleeping for 5 mins before a retry (max tries $maxTries)" 1>&2
            sleep 5m
        else
            echo "Still failing but retries exceeded, no more retries" 1>&2
        fi
    fi

    # Just remove any leading spaces from fails
    fails=$(echo -e "$newFails" | sed 's/^ //')

done

if [ -n "$fails" ]; then
    echo "Some suggesters never succeeded: $fails" 1>&2
    exit 1
else
    echo "All suggesters succeeded in the end"
fi
