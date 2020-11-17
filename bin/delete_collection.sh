#!/usr/bin/env bash
set -e

[ -z ${SOLR_COLLECTION+x} ] && echo "SOLR_COLLECTION env var is needed." && exit 1
HOST=${SOLR_HOST:-localhost:8983}

curl "http://$HOST/solr/admin/collections?action=DELETE&name=$SOLR_COLLECTION"
