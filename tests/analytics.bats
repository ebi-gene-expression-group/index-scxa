Solrsetup() {
  export SOLR_COLLECTION=scxa-analytics-v4
}

@test "Check that curl is in the path" {
    run which curl
    [ "$status" -eq 0 ]
}

@test "Check that awk is in the path" {
    run which awk
    [ "$status" -eq 0 ]
}

@test "Check that jq is in the path" {
    run which jq
    [ "$status" -eq 0 ]
}

@test "Check that sdrf converter is in the path" {
    run which condSdrf2tsvForSCXAJSONFactorsIndex.sh
    [ "$status" -eq 0 ]
}

@test "Check that cell id grouper is in the path" {
    run which jsonGroupByCellID.sh
    [ "$status" -eq 0 ]
}

@test "Check that filtering script is in the path" {
    run which jsonFilterEmptyFields.sh
    [ "$status" -eq 0 ]
}

@test "Check valid json output from sdrf converter" {
    condSdrf2tsvForSCXAJSONFactorsIndex.sh $BATS_TEST_DIRNAME/example-conds-sdrf.tsv | jq -s .
    [  $? -eq 0 ]
}

@test "Check that filtering doesn't remove any cell IDs" {
    CELL_ID_COUNT=`condSdrf2tsvForSCXAJSONFactorsIndex.sh $BATS_TEST_DIRNAME/example-conds-sdrf.tsv | jsonFilterEmptyFields.sh | grep \"cell_id\": | sort -u | wc -l`
    UNIQUE_CELL_ID_COUNT=`condSdrf2tsvForSCXAJSONFactorsIndex.sh $BATS_TEST_DIRNAME/example-conds-sdrf.tsv | grep \"cell_id\": | sort -u | wc -l`
    [ $CELL_ID_COUNT = $UNIQUE_CELL_ID_COUNT ]
}

@test "[analytics] Create collection on Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on Solr"
  fi
  if [ ! -z ${SOLR_COLLECTION_EXISTS+x} ]; then
    skip "Solr collection has been predifined on the current setup"
  fi
  run create-scxa-analytics-config-set.sh
  run create-scxa-analytics-collection.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Set no auto-create on Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on Solr"
  fi
  run scxa-config-set-no-autocreate.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Load schema to collection on Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on Solr"
  fi
  run create-scxa-analytics-schema.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Check that all fields are in the created schema" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping check of fields on schema"
  fi
  run analytics-check-created-fields.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Load data to Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export CONDENSED_SDRF_TSV=$BATS_TEST_DIRNAME/example-conds-sdrf.tsv
  run load_scxa_analytics_index.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Load additional dataset for deletion testing" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export EXP_ID=E-GEOD-DELETE
  export CONDENSED_SDRF_TSV=$BATS_TEST_DIRNAME/example-conds-sdrf-delete.tsv
  sed s/E-GEOD-106540/$EXP_ID/ $BATS_TEST_DIRNAME/example-conds-sdrf.tsv > $CONDENSED_SDRF_TSV
  run load_scxa_analytics_index.sh && rm $CONDENSED_SDRF_TSV && analytics-check-experiment-available.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test '[analytics] Delete additional dataset' {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export EXP_ID=E-GEOD-DELETE
  run delete_scxa_analytics_index.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Check correctness of load" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export CONDENSED_SDRF_TSV=$BATS_TEST_DIRNAME/example-conds-sdrf.tsv
  run analytics-check-index-content.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test '[analytics] Check that deleted experiment is no longer available, but previous one is' {
  export EXP_ID=E-GEOD-DELETE
  run analytics-check-experiment-available.sh
  # this will return exit code 1 if the experiment is not available
  [ "$status" -eq 1 ]
  export EXP_ID=E-GEOD-106540
  run analytics-check-experiment-available.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test '[analytics] Delete collection' {
  run delete_collection.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Check that there is nothing loaded" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export CONDENSED_SDRF_TSV=$BATS_TEST_DIRNAME/example-conds-sdrf.tsv
  run analytics-check-index-content.sh
  echo "output = ${output}"
  [ "$status" -ne 0 ]
}

@test '[analytics] Re-create collection' {
  export SOLR_NUM_SHARD=1
  run create-scxa-analytics-collection.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Set no auto-create on Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on Solr"
  fi
  run scxa-config-set-no-autocreate.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Re-Load schema to collection on Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on Solr"
  fi
  run create-scxa-analytics-schema.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Re-Check that all fields are in the created schema" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping check of fields on schema"
  fi
  run analytics-check-created-fields.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Load data to Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export CONDENSED_SDRF_TSV=$BATS_TEST_DIRNAME/example-conds-sdrf.tsv
  run load_scxa_analytics_index.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Load additional dataset for deletion testing" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export EXP_ID=E-GEOD-DELETE
  export CONDENSED_SDRF_TSV=$BATS_TEST_DIRNAME/example-conds-sdrf-delete.tsv
  sed s/E-GEOD-106540/$EXP_ID/ $BATS_TEST_DIRNAME/example-conds-sdrf.tsv > $CONDENSED_SDRF_TSV
  run load_scxa_analytics_index.sh && rm $CONDENSED_SDRF_TSV && analytics-check-experiment-available.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test '[analytics] Delete additional dataset' {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export EXP_ID=E-GEOD-DELETE
  run delete_scxa_analytics_index.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Check correctness of load" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export CONDENSED_SDRF_TSV=$BATS_TEST_DIRNAME/example-conds-sdrf.tsv
  run analytics-check-index-content.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}
