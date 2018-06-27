#!/usr/bin/env bash
SCHEMA_VERSION=1

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"scxa-gene2experiment-v$SCHEMA_VERSION"}

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
printf "\n\nDelete field bioentity_identifier "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field" :
  {
    "name": "bioentity_identifier"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate field bioentity_identifier (string) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "bioentity_identifier",
    "type": "string",
    "docValues": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete update processor "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-updateprocessor": "'$CORE'_dedup"
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
    "fields": "bioentity_identifier,experiment_accession",
    "signatureClass": "solr.processor.Lookup3Signature"
  }
}' http://$HOST/solr/$CORE/config
