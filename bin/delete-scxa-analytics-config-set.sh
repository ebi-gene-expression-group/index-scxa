#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. ${DIR}/scxa-analytics-schema-version.env

export SOLR_COLLECTION=scxa-analytics-v$SCHEMA_VERSION
HOST=${SOLR_HOST:-localhost:8983}
CONFIG=$SOLR_COLLECTION

curl "http://$HOST/solr/admin/configs?action=DELETE&name=$CONFIG"
