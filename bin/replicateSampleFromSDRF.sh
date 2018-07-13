#!/usr/bin/env bash

# Obtain column number for Comment [ *run ] (run_id/cell_id) and for
# Comment[technical replicate group]
columnRun=$(head -n 1 $SDRF_FILE | sed 's/\t/\n/g' | awk -F'\t' '{ if( $s ~ /^Comment\s{0,1}\[.*RUN\]/ ) { print NR } }' )
columnTechRep=$(head -n 1 $SDRF_FILE | sed 's/\t/\n/g' | awk -F'\t' '{ if( $s ~ /^Comment\s{0,1}\[technical replicate group\]/ ) { print NR } }' )

tail -n +2 $SDRF_FILE | awk -v c1=$columnRun -v c2=$columnTechRep -F'\t' '{ print "{ \"cell_id\": \""$c1"\",\n \"sample_id\": \""$c2"\" }" }' | jq -s .
