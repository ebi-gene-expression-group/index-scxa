#!/bin/bash

DIR=$(dirname ${BASH_SOURCE[0]})
export PATH=$DIR/../bin:$DIR/../tests:$DIR/../tests/genes2experiment:$PATH

# Solr auth
export SOLR_USER=$ADMIN_USER
export SOLR_PASS=$ADMIN_U_PWD