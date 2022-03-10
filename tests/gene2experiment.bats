setup() {
  export SOLR_COLLECTION=scxa-gene2experiment-v1
}

@test "[gene2experiment] Check that matrixMarktGenes2json is in the path" {
    run which matrixMarktGenes2json.sh
    [ "$status" -eq 0 ]
}

@test "[gene2experiment] Check valid json output from matrixMarktGenes2json" {
    export MATRIX_MARKT_ROWS_GENES_FILE=$BATS_TEST_DIRNAME/gene2experiment/matrixMarkt-genes.mtx_rows
    export EXP_ID="MyExp"
    matrixMarktGenes2json.sh  | jq .
    [  $? -eq 0 ]
}

@test "[gene2experiment] Create collection on Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on Solr"
  fi
  if [ ! -z ${SOLR_COLLECTION_EXISTS+x} ]; then
    skip "Solr collection has been predefined on the current setup"
  fi
  run create-scxa-gene2experiment-config-set.sh
  run create-scxa-gene2experiment-collection.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[gene2experiment] Set no auto-create on Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on Solr"
  fi
  export SCHEMA_VERSION=1
  export SOLR_COLLECTION=scxa-gene2experiment-v$SCHEMA_VERSION
  run scxa-config-set-no-autocreate.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[gene2experiment] Load schema to collection on Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on Solr"
  fi
  run create-scxa-gene2experiment-schema.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[gene2experiment] Load data to Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export MATRIX_MARKT_ROWS_GENES_FILE=$BATS_TEST_DIRNAME/gene2experiment/matrixMarkt-genes.mtx_rows
  export EXP_ID="MyExp"
  run load-scxa-gene2experiment.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[gene2experiment] Check correctness of load" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export MATRIX_MARKT_ROWS_GENES_FILE=$BATS_TEST_DIRNAME/gene2experiment/matrixMarkt-genes.mtx_rows
  export EXP_ID="MyExp"
  run gene2experiment-check-index-content.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[gene2experiment] Optimise collection" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to Solr"
  fi

  run optimise-analytics.sh

  echo "output = ${output}"
  [ "${status}" -eq 0 ]
}

@test "[gene2experiment] Check that optimisation worked" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to Solr"
  fi
  run analytics-check-optimisation.sh

  echo "output = ${output}"
  [ "${status}" -eq 0 ]
}

@test "[gene2experiment] Delete data for experiment" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export EXP_ID="MyExp"
  run delete-scxa-gene2experiment-exp-entries.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[gene2experiment] Check records deletion" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export MATRIX_MARKT_ROWS_GENES_FILE=/dev/null
  export EXP_ID="MyExp"
  run delete-scxa-gene2experiment-exp-entries.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}
