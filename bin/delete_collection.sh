#!/usr/bin/env bash
set -e

[ -z ${SOLR_COLLECTION+x} ] && echo "SOLR_COLLECTION env var is needed." && exit 1
HOST=${SOLR_HOST:-localhost:8983}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

curl $SOLR_AUTH "http://$HOST/solr/admin/collections?action=DELETE&name=$SOLR_COLLECTION"
