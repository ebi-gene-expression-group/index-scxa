#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. ${DIR}/../bin/scxa-analytics-schema-version.env

HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"scxa-analytics-v$SCHEMA_VERSION"}

curl "http://${SOLR_HOST}/solr/admin/collections?action=CLUSTERSTATUS&collection=${COLLECTION}" | jq '..|.replicas? | select( . != null ) | to_entries | .[] | .value | (.base_url|tostring)+"/admin/cores?action=STATUS&core="+(.core|tostring)' | xargs curl -s | jq '..|.deletedDocs? | select( . != null )' | uniq
