#!/usr/bin/env bash
SCHEMA_VERSION=5

#This below long curl request build suggestions on the solr server for the mentioned dictionaries as part of http request
#Once build request completes, user can search for the suggestions
# To search for the suggestions, here is the curl request:
# curl -X GET 'http://localhost:8983/solr/scxa-analytics-v5/suggest?suggest=true&suggest.dictionary=ontologyAnnotationSuggester&suggest.dictionary=ontologyAnnotationAncestorSuggester&suggest.dictionary=ontologyAnnotationParentSuggester&suggest.dictionary=ontologyAnnotationSynonymSuggester&suggest.dictionary=ontologyAnnotationChildSuggester&suggest.q=skin'

# on developers environment export SOLR_HOST and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"scxa-analytics-v${SCHEMA_VERSION}"}

curl "http://$HOST/solr/$COLLECTION/suggest?suggest=true&suggest.build=true&suggest.dictionary=ontologyAnnotationSuggester&suggest.dictionary=ontologyAnnotationAncestorSuggester&suggest.dictionary=ontologyAnnotationParentSuggester&suggest.dictionary=ontologyAnnotationSynonymSuggester&suggest.dictionary=ontologyAnnotationChildSuggester"

