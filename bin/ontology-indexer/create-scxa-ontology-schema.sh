#!/usr/bin/env bash
SCHEMA_VERSION=1

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
CORE=${SOLR_COLLECTION:-"scxa-ontology-v$SCHEMA_VERSION"}

#############################################################################################

printf "\n\nDelete field ancestor_uris"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "ancestor_uris"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate field ancestor_uris (string, multiValued)"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "ancestor_uris",
    "type": "string",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field child_hierarchy"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field" :
  {
    "name": "child_hierarchy"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate field child_hierarchy (string) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "child_hierarchy",
    "type": "string",
    "indexed": false
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field child_uris"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "child_uris"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate child_uris (string, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "child_uris",
    "type": "string",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field descendant_uris"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "descendant_uris"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate descendant_uris (string, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "descendant_uris",
    "type": "string",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field description"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "description"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate description (text_general, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "description",
    "type": "text_general",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field equivalent_uris"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "equivalent_uris"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate equivalent_uris (string, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "equivalent_uris",
    "type": "string",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field is_defining_ontology"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "is_defining_ontology"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate is_defining_ontology (boolean) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "is_defining_ontology",
    "type": "boolean"
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field is_defining_ontology"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "is_defining_ontology"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate is_defining_ontology (boolean) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "is_defining_ontology",
    "type": "boolean"
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field is_obsolete"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "is_obsolete"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate is_obsolete (boolean) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "is_obsolete",
    "type": "boolean"
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field is_root"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "is_root"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate is_root (boolean) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "is_root",
    "type": "boolean"
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field label"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "label"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate label (text_general, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "label",
    "type": "text_general",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field logical_descriptions"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "logical_descriptions"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate logical_descriptions (string, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "logical_descriptions",
    "type": "string",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field parent_uris"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "parent_uris"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate parent_uris (string, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "parent_uris",
    "type": "string",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field short_form"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "short_form"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate short_form (string, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "short_form",
    "type": "string",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field source"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "source"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate source (string) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "source",
    "type": "string"
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field synonyms"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "synonyms"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate synonyms (text_general_rev, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "synonyms",
    "type": "text_general_rev",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field tree_level"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "tree_level"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate tree_level (pint) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "tree_level",
    "type": "pint"
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field type"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "type"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate type (string) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "type",
    "type": "string"
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field uri"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "uri"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate uri (string) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "uri",
    "type": "string"
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete field uri_key"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "uri_key"
  }
}' http://$HOST/solr/$CORE/schema

printf "\n\nCreate uri_key (pint) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "uri_key",
    "type": "pint"
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nDelete dynamic field rule *_rel"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":
  {
    "name": "*_rel"
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nCreate dynamic field rule *_rel (string, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field":
  {
    "name": "*_rel",
    "type": "string",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

# #############################################################################################

printf "\n\nDelete dynamic field rule *_annotation"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field":
  {
    "name": "*_annotation"
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################################

printf "\n\nCreate dynamic field rule *_annotation (string, multiValued) "
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field":
  {
    "name": "*_annotation",
    "type": "string",
    "multiValued": true
  }
}' http://$HOST/solr/$CORE/schema

#############################################################################

printf "\n\nDisable autoCreateFields (aka “Data driven schema”)"
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "set-user-property": {
    "update.autoCreateFields": "false"
  }
}' http://$HOST/solr/$CORE/config
