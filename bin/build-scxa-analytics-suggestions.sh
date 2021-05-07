#!/bin/bash

#This below long curl request build suggestions on the solr server for the mentioned dictionaries as part of http request
#Once build request completes, user can search for the suggestions
# To search for the suggestions, here is the curl request:
# curl -X GET 'http://localhost:8983/solr/scxa-analytics-v5/suggest?suggest=true&suggest.dictionary=ontologyAnnotationSuggester&suggest.dictionary=ontologyAnnotationAncestorSuggester&suggest.dictionary=ontologyAnnotationParentSuggester&suggest.dictionary=ontologyAnnotationSynonymSuggester&suggest.dictionary=ontologyAnnotationChildSuggester&suggest.q=skin'

curl -X GET 'http://localhost:8983/solr/scxa-analytics-v5/suggest?suggest=true&suggest.build=true&suggest.dictionary=ontologyAnnotationSuggester&suggest.dictionary=ontologyAnnotationAncestorSuggester&suggest.dictionary=ontologyAnnotationParentSuggester&suggest.dictionary=ontologyAnnotationSynonymSuggester&suggest.dictionary=ontologyAnnotationChildSuggester'

