# Modules for loading atlas data into solr

## SCXA Condensed SDRF to sc-analytics schema

This module loads data from a condensed SDRF in an SCXA experiment to the sc-analytics collection in solr. These routines expect the collection to be created already, and work as an update to the content of the collection.

```
$ export SOLR_HOST=192.168.99.100:32080
$ export SOLR_COLLECTION=sc-analytics
$ export CONDENSED_SDRF_TSV=../scxa-test-experiments/magetab/E-GEOD-106540/E-GEOD-106540.condensed-sdrf.tsv

$ condSdrf2tsvForSCXAJSONFactorsIndex.sh $CONDENSED_SDRF_TSV | jsonGroupByCellID.sh | loadFactorsIndexToSolr.sh
```
