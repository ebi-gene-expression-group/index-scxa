#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. ${DIR}/scxa-analytics-schema-version.env

export SOLR_COLLECTION=scxa-analytics-v$SCHEMA_VERSION
HOST=${SOLR_HOST:-localhost:8983}

set -e

[ -z ${EXP_ID+x} ] && echo "EXP_ID env var is needed." && exit 1

curl "http://$HOST/solr/$SOLR_COLLECTION/update?commit=true" -H "Content-Type: text/xml" \
  --data-binary "<delete><query>experiment_accession:$EXP_ID</query></delete>"
