#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. ${DIR}/scxa-analytics-schema-version.env

# The curl request below builds suggesters on Solr. When the request completes you may search for suggestions. E.g.:
# curl -X GET 'http://${HOST}/solr/${COLLECTION}/suggest?suggest=true&suggest.dictionary=ontologyAnnotationSuggester&suggest.dictionary=ontologyAnnotationAncestorSuggester&suggest.dictionary=ontologyAnnotationParentSuggester&suggest.dictionary=ontologyAnnotationSynonymSuggester&suggest.dictionary=ontologyAnnotationChildSuggester&suggest.q=skin'

# on developers environment export SOLR_HOST and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"scxa-analytics-v${SCHEMA_VERSION}"}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

REQUEST_URI="http://$HOST/solr/$COLLECTION/suggest?suggest=true"
BUILD=${BUILD_SUGGESTERS:-true}

# Build suggesters one by one
if [ "$BUILD" = true ] ; then
    for SUGGESTER in ontologyAnnotationSuggester ontologyAnnotationAncestorSuggester ontologyAnnotationParentSuggester ontologyAnnotationSynonymSuggester; do

        echo "Building $suggester"    
        
        # For some reason the error trace that can come back invalidates the
        # JSON so we need some 'tr' and 'sed' magic
        
        RESPONSE=$(curl $SOLR_AUTH "$REQUEST_URI&suggest.build=true&suggest.dictionary=$SUGGESTER")
        RESPONSE=$(echo -e "$RESPONSE" | tr -d '\n' | sed 's/\t/ /g')
        STATUS_CODE=$(echo -e "$RESPONSE" | jq '.responseHeader.status')
        
        if [ "$STATUS_CODE" -eq '0' ]; then
            echo "Successfully built suggester: $SUGGESTER"

            echo -e "Failed to build suggester $SUGGESTER, response was: \n\n$RESPONSE\n" 1>&2