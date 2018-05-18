#!/usr/bin/env bash
SCHEMA_VERSION=2

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"scxa-analytics-v$SCHEMA_VERSION"}

#############################################################################################

printf "\n\nDelete field experiment_accession"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "experiment_accession"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate field experiment_accession (string)"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "experiment_accession",
    "type": "string",
    "docValues": true
  }
}' http://$HOST/solr/$CORE/schema



#############################################################################################
# TODO hacer congruente con cell_id
printf "\n\nDelete field cell_id"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field" :
  {
    "name": "cell_id"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate field cell_id (string)"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "cell_id",
    "type": "string",
    "docValues": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field factors"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "factors"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate field factors (string, multiValued)"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "factors",
    "type": "string",
    "multiValued": true,
    "docValues": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field characteristics"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "characteristics"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate field characteristics (string, multiValued)"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "characteristics",
    "type": "string",
    "multiValued": true,
    "docValues": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################
# Deletion of copy field needs to come before the deletion of the actual fields.
# 1.1
printf "\n\nDelete copy field for facet_factor_*"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-copy-field":{
     "source":"factor_*",
     "dest": "facet_factor_*" }
}' http://$HOST/solr/$CORE/schema

#############################################################################################
# 1.2
printf "\n\nDelete dynamic field factor_*"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":
  {
    "name": "factor_*"
  }
}' http://$HOST/solr/$CORE/schema
# 1.3
printf "\n\nCreate dynamic rule factor_* (lowercase, multiValued)"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field":
  {
    "name": "factor_*",
    "type": "lowercase",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################
# 1.4
printf "\n\nDelete dynamic field facet_factor_*"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":
  {
    "name": "facet_factor_*"
  }
}' http://$HOST/solr/$CORE/schema
# 1.5
printf "\n\nCreate dynamic rule facet_factor_* (lowercase, multiValued)"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field":
  {
    "name": "facet_factor_*",
    "type": "string",
    "multiValued": true,
    "docValues": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################
# 1.6
printf "\n\nCreate copy field for facet_factor_* (lowercase, multiValued)"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-copy-field":{
     "source":"factor_*",
     "dest": "facet_factor_*" }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

#############################################################################################
# Deletion of copy field needs to come before the deletion of the actual fields.
# 2.1
printf "\n\nDelete copy field for facet_characteristic_*"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-copy-field":{
     "source":"characteristic_*",
     "dest": "facet_characteristic_*" }
}' http://$HOST/solr/$CORE/schema

#############################################################################################
# 2.2
printf "\n\nDelete dynamic field characteristic_*"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":
  {
    "name": "characteristic_*"
  }
}' http://$HOST/solr/$CORE/schema
# 2.3
printf "\n\nCreate dynamic rule characteristic_* (lowercase, multiValued)"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field":
  {
    "name": "characteristic_*",
    "type": "lowercase",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################
# 2.4
printf "\n\nDelete dynamic field facet_characteristic_*"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":
  {
    "name": "facet_characteristic_*"
  }
}' http://$HOST/solr/$CORE/schema
# 2.5
printf "\n\nCreate dynamic rule facet_characteristic_* (lowercase, multiValued)"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field":
  {
    "name": "facet_characteristic_*",
    "type": "string",
    "multiValued": true,
    "docValues": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################
# 2.6
printf "\n\nCreate copy field for facet_characteristic_* (lowercase, multiValued)"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-copy-field":{
     "source":"characteristic_*",
     "dest": "facet_characteristic_*" }
}' http://$HOST/solr/$CORE/schema

#############################################################################################



printf "\n\nDelete field conditions_search"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field" :
  {
    "name": "conditions_search"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nDelete field type text_en_tight"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field-type":
  {
    "name": "text_en_tight"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate field type text_en_tight"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field-type": {
    "name": "text_en_tight",
    "class": "solr.TextField",
    "positionIncrementGap": "100",
    "analyzer" : {
      "tokenizer": {
        "class": "solr.WhitespaceTokenizerFactory"
      },
      "filters": [
        {
          "class":"solr.LowerCaseFilterFactory"
        },
        {
          "class":"solr.EnglishPossessiveFilterFactory"
        },
        {
          "class":"solr.PorterStemFilterFactory"
        }
      ]
    }
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate field conditions_search (text_en_tight)"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "conditions_search",
    "type": "text_en_tight"
  }
}' http://$HOST/solr/$CORE/schema


#############################################################################################

printf "\n\nDelete field signatureField"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "id"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate field signatureField for dedup"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "id",
    "stored": "true",
    "indexed": "true"
    "type": "string",
    "multiValued": "false"
  }
}' http://$HOST/solr/$CORE/schema


#############################################################################
printf "\n\nDelete update processor"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-updateprocessor":
  {
    "name": "scxa_analytics_dedup"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate update processor"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-updateprocessor":
  {
    "name": "scxa_analytics_dedup"
    "class": "solr.processor.SignatureUpdateProcessorFactory",
    "enabled": "true",
    "signatureField": "id",
    "overwriteDupes": "true",
    "fields": "cell_id,experiment_accession",
    "signatureClass": "solr.processor.Lookup3Signature"
  }
}' http://$HOST/solr/$CORE/config
