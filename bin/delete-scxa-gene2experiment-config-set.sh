#!/usr/bin/env bash
export SCHEMA_VERSION=1
export SOLR_COLLECTION=scxa-gene2experiment-v$SCHEMA_VERSION
HOST=${SOLR_HOST:-localhost:8983}
CONFIG=$SOLR_COLLECTION

curl "http://$HOST/solr/admin/configs?action=DELETE&name=$CONFIG"
