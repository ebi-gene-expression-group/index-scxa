setup() {
  export SOLR_COLLECTION=scxa-analytics-v7
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
    run which jsonl-filter-empty-string-values.sh
    [ "$status" -eq 0 ]
}

@test "Check valid json output from sdrf converter" {
    condSdrf2tsvForSCXAJSONFactorsIndex.sh $BATS_TEST_DIRNAME/example-conds-sdrf.tsv | jq -s .
    [  $? -eq 0 ]
}

@test "[solr-auth] Create definitive users" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on Solr"
  fi

  # default user to start - admin user will be used by other tasks
  export SOLR_USER=solr
  export SOLR_PASS=SolrRocks

  echo "Solr user: $SOLR_USER"
  echo "Solr pwd: $SOLR_PASS"

  run create-users.sh
  echo "output = ${output}"
  [ "${status}" -eq 0 ]
}

@test "Check that filtering doesn't remove any cell IDs" {
    # extra jq . below reformats JSON lines into one line per field to satisfy line uniquenes per cell id.
    CELL_ID_COUNT=`condSdrf2tsvForSCXAJSONFactorsIndex.sh $BATS_TEST_DIRNAME/example-conds-sdrf.tsv | jsonl-filter-empty-string-values.sh | jq . | grep \"cell_id\": | sort -u | wc -l`
    UNIQUE_CELL_ID_COUNT=`condSdrf2tsvForSCXAJSONFactorsIndex.sh $BATS_TEST_DIRNAME/example-conds-sdrf.tsv | jq . | grep \"cell_id\": | sort -u | wc -l`
    [ $CELL_ID_COUNT = $UNIQUE_CELL_ID_COUNT ]
}

@test "Upload biosolr lib" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on Solr"
  fi

  run upload-biosolr-lib.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
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

@test "Fetch SCXA OWL file" {
    run wget -O ${BATS_TEST_DIRNAME}/scatlas.owl https://raw.githubusercontent.com/EBISPOT/scatlas_ontology/zooma_file_proc_release/scatlas.owl
    [ -s "${BATS_TEST_DIRNAME}/scatlas.owl" ]
}

@test "[analytics] Load schema to collection on Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of schema on Solr"
  fi
  export SCXA_ONTOLOGY="file://${BATS_TEST_DIRNAME}/scatlas.owl"
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
  run load-scxa-analytics.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Load additional dataset for deletion testing 1" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export EXP_ID=E-GEOD-DELETE
  export CONDENSED_SDRF_TSV=$BATS_TEST_DIRNAME/example-conds-sdrf-delete.tsv

  sed s/E-GEOD-106540/$EXP_ID/ $BATS_TEST_DIRNAME/example-conds-sdrf.tsv > $CONDENSED_SDRF_TSV
  run load-scxa-analytics.sh && rm $CONDENSED_SDRF_TSV && analytics-check-experiment-available.sh
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

@test "[analytics] Check that there is nothing loaded" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export CONDENSED_SDRF_TSV=$BATS_TEST_DIRNAME/example-conds-sdrf.tsv
  run analytics-check-index-content.sh
  echo "output = ${output}"
  [ "$status" -ne 0 ]
}

@test '[analytics] Delete collection' {
  run delete_collection.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test '[analytics] Re-create collection' {
  export SOLR_NUM_SHARD=1
  run create-scxa-analytics-collection.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Set no auto-create on Solr 2" {
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
  export SCXA_ONTOLOGY="file://${BATS_TEST_DIRNAME}/scatlas.owl"
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

@test "[analytics] Load data to Solr 2" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export CONDENSED_SDRF_TSV=$BATS_TEST_DIRNAME/example-conds-sdrf.tsv
  export NUM_DOCS_PER_BATCH=20
  run load-scxa-analytics.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Load additional dataset for deletion testing 2" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export EXP_ID=E-GEOD-DELETE
  export CONDENSED_SDRF_TSV=$BATS_TEST_DIRNAME/example-conds-sdrf-delete.tsv
  
  sed s/E-GEOD-106540/$EXP_ID/ $BATS_TEST_DIRNAME/example-conds-sdrf.tsv > $CONDENSED_SDRF_TSV
  run load-scxa-analytics.sh && rm $CONDENSED_SDRF_TSV && analytics-check-experiment-available.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test '[analytics] Delete additional dataset 2' {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export EXP_ID=E-GEOD-DELETE
  run delete_scxa_analytics_index.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Check correctness of load 2" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to SOLR"
  fi
  export CONDENSED_SDRF_TSV=$BATS_TEST_DIRNAME/example-conds-sdrf.tsv
  run analytics-check-index-content.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] Optimise collection" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to Solr"
  fi

  run optimise-analytics.sh

  echo "output = ${output}"
  [ "${status}" -eq 0 ]
}

@test "[analytics] Check that analytics optimisation worked" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping load to Solr"
  fi
  run analytics-check-optimisation.sh

  echo "output = ${output}"
  [ "${status}" -eq 0 ]
}

@test "[analytics] Reload suggesters to collection on Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skipping loading of suggesters on Solr"
  fi

  run create-scxa-analytics-suggesters.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] build suggesters on Solr" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skip building of suggesters on Solr"
  fi
  run build-scxa-analytics-suggestions.sh

  run analytics-check-suggesters.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "[analytics] all suggestions contain a non-empty payloadField" {
  if [ -z ${SOLR_HOST+x} ]; then
    skip "SOLR_HOST not defined, skip building of suggesters on Solr"
  fi
  #run build-scxa-analytics-suggestions.sh

  run analytics-check-suggesters-payload.sh
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}
