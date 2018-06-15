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

@test "Check valid json output from sdrf converter" {
    condSdrf2tsvForSCXAJSONFactorsIndex.sh $BATS_TEST_DIRNAME/example-conds-sdrf.tsv | jq .
    [  $? -eq 0 ]
}

@test "Check that cell ids get grouped properly" {
    CELL_ID_COUNT=`condSdrf2tsvForSCXAJSONFactorsIndex.sh $BATS_TEST_DIRNAME/example-conds-sdrf.tsv | jsonGroupByCellID.sh | grep -c \"cell_id\":`
    UNIQUE_CELL_ID_COUNT=`condSdrf2tsvForSCXAJSONFactorsIndex.sh $BATS_TEST_DIRNAME/example-conds-sdrf.tsv | grep \"cell_id\": | sort -u | grep -c \"cell_id\"`
    [ $CELL_ID_COUNT = $UNIQUE_CELL_ID_COUNT ]
}

@test "[analytics] Create collection on solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on solr"
  fi
  if [ ! -z ${SOLR_COLLECTION_EXISTS+x} ]; then
    skip "solr collection has been predifined on the current setup"
  fi
  create-fake-collection-for-config-set.sh
  run create-scxa-analytics-collection.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Set no auto-create on solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on solr"
  fi
  export SOLR_COLLECTION=scxa-analytics-v2
  run scxa-index-set-no-autocreate.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Load schema to collection on solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on solr"
  fi
  run create-scxa-analytics-schema.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Check that all fields are in the created schema" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping check of fields on schema"
  fi
  run check-created-fields.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Load data to solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export CONDENSED_SDRF_TSV=$BATS_TEST_DIRNAME/example-conds-sdrf.tsv
  run load_scxa_analytics_index.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Check correctness of load" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export CONDENSED_SDRF_TSV=$BATS_TEST_DIRNAME/example-conds-sdrf.tsv
  run check-index-content.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}
