#!/usr/bin/env bash
SCHEMA_VERSION=1
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"scxa-gene2experiment-v$SCHEMA_VERSION"}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

curl $SOLR_AUTH "http://${SOLR_HOST}/solr/admin/collections?action=CLUSTERSTATUS&collection=${COLLECTION}" | jq '..|.replicas? | select( . != null ) | to_entries | .[] | .value | (.base_url|tostring)+"/admin/cores?action=STATUS&core="+(.core|tostring)' | xargs curl -s | jq '..|.deletedDocs? | select( . != null )' | uniq
