#!/usr/bin/env bash
set -e

HOST=${SOLR_HOST:-"localhost:8983"}

printf "\n\nCreating fake collection on $HOST to obtain a _default initial config"
curl "http://$HOST/solr/admin/collections?action=CREATE&name=fakeCollection&numShards=1"
