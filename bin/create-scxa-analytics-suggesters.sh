#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. ${DIR}/schema-version.env

# On developers environment export SOLR_HOST and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"scxa-analytics-v${SCHEMA_VERSION}"}

#############################################################################################

printf "\n\nDelete search component for suggesters"
CURL -X POST -H 'Content-Type: application/json' -d '{
  "delete-searchcomponent" : "suggest"
}' http://${HOST}/solr/${COLLECTION}/config


printf "\n\nCreate search component for suggesters"
CURL -X POST -H 'Content-Type: application/json' -d '{
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
            "payloadField": "ontology_annotation_label_t",
            "suggestAnalyzerFieldType": "text_en",
            "queryAnalyzerFieldType": "text_en",
            "buildOnStartup": "false"
           },
           {
            "name": "ontologyAnnotationAncestorSuggester",
            "indexPath": "ontologyAnnotationAncestorSuggester",
            "lookupImpl": "AnalyzingInfixLookupFactory",
            "dictionaryImpl": "DocumentDictionaryFactory",
            "field": "ontology_annotation_ancestors_labels_t",
            "payloadField": "ontology_annotation_ancestors_labels_t",
            "suggestAnalyzerFieldType": "text_en",
            "queryAnalyzerFieldType": "text_en",
            "buildOnStartup": "false"
            }
            ,
            {
                "name": "ontologyAnnotationParentSuggester",
                "indexPath": "ontologyAnnotationParentSuggester",
                "lookupImpl": "AnalyzingInfixLookupFactory",
                "dictionaryImpl": "DocumentDictionaryFactory",
                "field": "ontology_annotation_parent_labels_t",
                "payloadField": "ontology_annotation_parent_labels_t",
                "suggestAnalyzerFieldType": "text_en",
                "queryAnalyzerFieldType": "text_en",
                "buildOnStartup": "false"
            },
            {
                "name": "ontologyAnnotationSynonymSuggester",
                "indexPath": "ontologyAnnotationSynonymSuggester",
                "lookupImpl": "AnalyzingInfixLookupFactory",
                "dictionaryImpl": "DocumentDictionaryFactory",
                "field": "ontology_annotation_synonyms_t",
                "payloadField": "ontology_annotation_synonyms_t",
                "suggestAnalyzerFieldType": "text_en",
                "queryAnalyzerFieldType": "text_en",
                "buildOnStartup": "false"
            },
            {
                "name": "ontologyAnnotationChildSuggester",
                "indexPath": "ontologyAnnotationChildSuggester",
                "lookupImpl": "AnalyzingInfixLookupFactory",
                "dictionaryImpl": "DocumentDictionaryFactory",
                "field": "ontology_annotation_child_labels_t",
                "payloadField": "ontology_annotation_child_labels_t",
                "suggestAnalyzerFieldType": "text_en",
                "queryAnalyzerFieldType": "text_en",
                "buildOnStartup": "false"
            }
       ]
    }
}' http://${HOST}/solr/${COLLECTION}/config

#############################################################################################

printf "\n\nDelete request handler /suggest"
CURL -X POST -H 'Content-Type: application/json' -d '{
    "delete-requesthandler" :  "/suggest"
}' http://${HOST}/solr/${COLLECTION}/config


printf "\n\nCreate request handler /suggest"
CURL -X POST -H 'Content-Type: application/json' -d '{
    "add-requesthandler" : {
        "name":"/suggest",
        "class":"solr.SearchHandler",
        "startup":"lazy",
        "defaults":{
        "suggest":"true",
        "suggest.count":100},
        "components":["suggest"]
    }
}' http://${HOST}/solr/${COLLECTION}/config
