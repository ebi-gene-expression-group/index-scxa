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


