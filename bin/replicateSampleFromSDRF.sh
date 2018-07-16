#!/usr/bin/env bash

set -e

[ -z ${SDRF_FILE+x} ] && echo "SDRF_FILE env var is needed." && exit 1
[ -z ${REPLICATE_MAPPING_FILE+x} ] && echo "REPLICATE_MAPPING_FILE env var is needed." && exit 1

# Obtain column number for Comment [ *run ] (run_id/cell_id) and for
# Comment[technical replicate group]
columnRun=$(head -n 1 $SDRF_FILE | sed 's/\t/\n/g' | awk -F'\t' '{ if( $s ~ /^Comment\s{0,1}\[.*RUN\]$/ ) { print NR } }' )
columnTechRep=$(head -n 1 $SDRF_FILE | sed 's/\t/\n/g' | awk -F'\t' '{ if( $s ~ /^Comment\s{0,1}\[technical replicate group\]$/ ) { print NR } }' )

if [[ ! $columnTechRep =~ ^-?[0-9]+$ ]]; then
  echo "No replicas column found, setting sample_id to the run_id value..."
  columnTechRep=$columnRun
else
  # Check that the technical replicates column has relevant values
  declare -a techReplicasContent
  readarray -t techReplicasContent < <(awk -v c1=$columnTechRep -F'\t' '{ print $c1 }' $SDRF_FILE | grep -v '^Comment' | sort -u)
  echo "Array size ${#techReplicasContent[@]}"

  # if the array only contains a single value, set it to point to columnRun as there are no replicates here either.
  if [ "${#techReplicasContent[@]}" = "1" ]; then
    echo "No replicas defined, setting sample_id to the run_id value..."
    columnTechRep=$columnRun
  fi
fi

# Generate json with cell_id to sample_id
tail -n +2 $SDRF_FILE | \
  awk -v c1=$columnRun -v c2=$columnTechRep -F'\t' \
      '{ print "{ \"cell_id\": \""$c1"\",\n \"sample_id\": \""$c2"\" }" }' \
      | jq -s . > $REPLICATE_MAPPING_FILE
