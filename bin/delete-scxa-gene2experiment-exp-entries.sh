#!/usr/bin/env bash
set -e

[ -z ${EXP_ID+x} ] && echo "EXP_ID env var is needed." && exit 1

export HOST=${SOLR_HOST:-$1}
export SCHEMA_VERSION=1
export COLLECTION=scxa-gene2experiment-v$SCHEMA_VERSION
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"

curl $SOLR_AUTH http://$HOST/solr/$COLLECTION/update?commit=true -H "Content-Type: text/xml" \
  --data-binary '<delete><query>experiment_accession:'$EXP_ID'</query></delete>'
