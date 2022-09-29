#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. ${DIR}/scxa-analytics-schema-version.env

HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"scxa-analytics-v${SCHEMA_VERSION}"}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

REQUEST_URI="http://$HOST/solr/$COLLECTION/suggest?suggest=true"
# I can’t find any query that produces results in all suggesters except one letter, maybe we should have richer
# fixtures if we want something more meaningful...
TEST_QUERY=h

set -e
for SUGGESTER in ontologyAnnotationSuggester ontologyAnnotationAncestorSuggester ontologyAnnotationParentSuggester ontologyAnnotationSynonymSuggester; do
  echo "$REQUEST_URI&suggest.dictionary=$SUGGESTER&suggest.q=$TEST_QUERY"
  curl $SOLR_AUTH -X GET "$REQUEST_URI&suggest.dictionary=$SUGGESTER&suggest.q=$TEST_QUERY" | \
  # Check that all suggestions have a non-empty payload
  jq -e ".suggest.$SUGGESTER.$TEST_QUERY.suggestions[] | select (.payload != \"\")" > /dev/null
done

exit 0
