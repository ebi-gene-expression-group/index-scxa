#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. ${DIR}/../scxa-analytics-schema-version.env

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


# On developers environment export SOLR_HOST and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"scxa-analytics-v${SCHEMA_VERSION}"}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

#############################################################################################

printf "\n\nDelete search component for suggesters"
curl $SOLR_AUTH -X POST -H 'Content-Type: application/json' -d '{
  "delete-searchcomponent" : "suggest"
}' http://${HOST}/solr/${COLLECTION}/config


printf "\n\nCreate search component for suggesters"
curl $SOLR_AUTH -X POST -H 'Content-Type: application/json' -d '{
  "add-searchcomponent": {
    "name": "suggest",
    "class": "solr.SuggestComponent",
    "suggester" : [
      {
        "name": "ontologyAnnotationSuggester",
        "indexPath": "ontologyAnnotationSuggester",
        "lookupImpl": "AnalyzingInfixLookupFactory",
        "dictionaryImpl": "DocumentDictionaryFactory",
        "field": "ontology_annotation_label_t",
        "payloadField": "ctw_organism",
        "suggestAnalyzerFieldType": "lowercase",
        "highlight": "false",
        "buildOnStartup": "false"
      },
      {
        "name": "ontologyAnnotationAncestorSuggester",
        "indexPath": "ontologyAnnotationAncestorSuggester",
        "lookupImpl": "AnalyzingInfixLookupFactory",
        "dictionaryImpl": "DocumentDictionaryFactory",
        "field": "ontology_annotation_ancestors_labels_t",
        "payloadField": "ctw_organism",
        "suggestAnalyzerFieldType": "lowercase",
        "highlight": "false",
        "buildOnStartup": "false"
      },
      {
        "name": "ontologyAnnotationParentSuggester",
        "indexPath": "ontologyAnnotationParentSuggester",
        "lookupImpl": "AnalyzingInfixLookupFactory",
        "dictionaryImpl": "DocumentDictionaryFactory",
        "field": "ontology_annotation_parent_labels_t",
        "payloadField": "ctw_organism",
        "suggestAnalyzerFieldType": "lowercase",
        "highlight": "false",
        "buildOnStartup": "false"
      },
      {
        "name": "ontologyAnnotationSynonymSuggester",
        "indexPath": "ontologyAnnotationSynonymSuggester",
        "lookupImpl": "AnalyzingInfixLookupFactory",
        "dictionaryImpl": "DocumentDictionaryFactory",
        "field": "ontology_annotation_synonyms_t",
        "payloadField": "ctw_organism",
        "suggestAnalyzerFieldType": "lowercase",
        "highlight": "false",
        "buildOnStartup": "false"
      }
	  ]
	}
}' http://${HOST}/solr/${COLLECTION}/config

#############################################################################################

printf "\n\nDelete request handler /suggest"
curl $SOLR_AUTH -X POST -H 'Content-Type: application/json' -d '{
  "delete-requesthandler": "/suggest"
}' http://${HOST}/solr/${COLLECTION}/config


printf "\n\nCreate request handler /suggest"
curl $SOLR_AUTH -X POST -H 'Content-Type: application/json' -d '{
  "add-requesthandler":
  {
    "name": "/suggest",
    "class": "solr.SearchHandler",
    "startup": "lazy",
    "defaults": {
      "suggest": true,
      "suggest.count": 100
    },
    "components": ["suggest"]
  }
}' http://${HOST}/solr/${COLLECTION}/config
