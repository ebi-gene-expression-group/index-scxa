#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. ${DIR}/../scxa-analytics-schema-version.env

HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"scxa-analytics-v${SCHEMA_VERSION}"}

REQUEST_URI="http://$HOST/solr/$COLLECTION/suggest?suggest=true"
TEST_QUERY=blood

set -e
for SUGGESTER in ontologyAnnotationSuggester ontologyAnnotationAncestorSuggester ontologyAnnotationParentSuggester ontologyAnnotationSynonymSuggester; do
  echo "$REQUEST_URI&suggest.dictionary=$SUGGESTER&suggest.q=$TEST_QUERY"
  curl -X GET "$REQUEST_URI&suggest.dictionary=$SUGGESTER&suggest.q=$TEST_QUERY" | \
  # Check that all suggestions have a non-empty payload
  jq -e ".suggest.$SUGGESTER.$TEST_QUERY.suggestions[] | select (.payload != \"\")" > /dev/null
done

exit 0
