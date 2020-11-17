#!/usr/bin/env bash
SCHEMA_VERSION=4

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"scxa-analytics-v$SCHEMA_VERSION"}

#############################################################################################

printf "\n\nDelete field experiment_accession "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "experiment_accession"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate field experiment_accession (string) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "experiment_accession",
    "type": "string",
    "docValues": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field cell_id "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field" :
  {
    "name": "cell_id"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate field cell_id (string) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "cell_id",
    "type": "string",
    "docValues": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field ontology_annotation "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "ontology_annotation"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate ontology_annotation (string, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "ontology_annotation",
    "type": "string",
    "multiValued": true,
    "docValues": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field ontology_synonyms "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "ontology_synonyms"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate ontology_synonyms (string, multiValued, docValues) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "ontology_synonyms",
    "type": "string",
    "multiValued": true,
    "docValues": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field ontology_definition "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "ontology_definition"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate ontology_synonyms (string, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "ontology_definition",
    "type": "string",
    "multiValued": true,
    "docValues": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################
# Deletion of copy field needs to come before the deletion of the actual fields.
# 1.1
printf "\n\nDelete copy field rule for facet_factor_* "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-copy-field":{
     "source": "factor_*",
     "dest": "facet_factor_*" }
}' http://$HOST/solr/$CORE/schema

#############################################################################################
# 1.2
printf "\n\nDelete dynamic field rule factor_* "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":
  {
    "name": "factor_*"
  }
}' http://$HOST/solr/$CORE/schema
# 1.3
printf "\n\nCreate dynamic field rule factor_* (lowercase, multiValued) "
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
printf "\n\nDelete dynamic field rule facet_factor_* "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":
  {
    "name": "facet_factor_*"
  }
}' http://$HOST/solr/$CORE/schema
# 1.5
printf "\n\nCreate dynamic field rule facet_factor_* (lowercase, multiValued) "
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
printf "\n\nCreate copy field rule factor_* -> facet_factor_* "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-copy-field":{
     "source": "factor_*",
     "dest": "facet_factor_*" }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

#############################################################################################
# Deletion of copy field needs to come before the deletion of the actual fields.
# 2.1
printf "\n\nDelete copy field rule characteristic_* -> facet_characteristic_* "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-copy-field":{
     "source": "characteristic_*",
     "dest": "facet_characteristic_*" }
}' http://$HOST/solr/$CORE/schema

#############################################################################################
# 2.2
printf "\n\nDelete dynamic field rule characteristic_* "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":
  {
    "name": "characteristic_*"
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################
# 2.3
printf "\n\nCreate dynamic field rule characteristic_* (lowercase, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field":
  {
    "name": "characteristic_*",
    "type": "lowercase",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

# #############################################################################################
# 2.4
printf "\n\nDelete dynamic field rule facet_characteristic_* "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":
  {
    "name": "facet_characteristic_*"
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################
# 2.5
printf "\n\nCreate dynamic field rule facet_characteristic_* (lowercase, multiValued) "
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
printf "\n\nCreate copy field rule characteristic_* -> facet_characteristic_* "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-copy-field":{
     "source": "characteristic_*",
     "dest": "facet_characteristic_*" }
}' http://$HOST/solr/$CORE/schema

#############################################################################################
# Fields required for BioSolr

printf "\n\nDelete dynamic field rule *_rel_iris "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":
  {
    "name": "*_rel_iris"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate dynamic field rule *_rel_iris (string, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field":
  {
    "name": "*_rel_iris",
    "type": "string",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nDelete dynamic field rule *_rel_labels "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":
  {
    "name": "*_rel_labels"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate dynamic field rule *_rel_iris (text_general, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field":
  {
    "name": "*_rel_labels",
    "type": "text_general",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nDelete dynamic field rule *_s "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":
  {
    "name": "*_s"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate dynamic field rule *_s (string, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field":
  {
    "name": "*_s",
    "type": "string",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nDelete dynamic field rule *_t "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":
  {
    "name": "*_t"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate dynamic field rule *_t (string, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field":
  {
    "name": "*_t",
    "type": "text_general",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################


printf "\n\nDelete update processor "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-updateprocessor": "'$CORE'_dedup"
}' http://$HOST/solr/$CORE/config


printf "\n\nDisable autoCreateFields (aka “Data driven schema”)"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "set-user-property": {
    "update.autoCreateFields": "false"
  }
}' http://$HOST/solr/$CORE/config


printf "\n\nCreate update processor "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-updateprocessor":
  {
    "name": "'$CORE'_dedup"
    "class": "solr.processor.SignatureUpdateProcessorFactory",
    "enabled": "true",
    "signatureField": "id",
    "overwriteDupes": "true",
    "fields": "experiment_accession,cell_id,characteristic_name,factor_name",
    "signatureClass": "solr.processor.Lookup3Signature"
  }
}' http://$HOST/solr/$CORE/config


printf "\n\nDelete ontology expansion update processor "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-updateprocessor": "'$CORE'_ontology_expansion"
}' http://$HOST/solr/$CORE/config


printf "\n\nCreate ontology expansion update processor "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-updateprocessor":
  {
    "name": "'$CORE'_ontology_expansion"
    "runtimeLib": true,
    "class": "uk.co.flax.biosolr.solr.update.processor.OntologyUpdateProcessorFactory",
    "enabled": "true",
    "annotationField": "ontology_annotation",
    "synonymsField": "ontology_synonyms",
    "definitionField": "",
    "childField": "",
    "descendantsField": "",
    "ontologyURI": "https://github.com/EBISPOT/scatlas_ontology/raw/master/scatlas.owl"
  }
}' http://$HOST/solr/$CORE/config
