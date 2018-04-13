# Modules for scxa-analytics solr index

Execution of tasks here require that `bin/` directory in the root of this repo is part of your path.

## Create schema

To create the schema, set the envronment variables `SOLR_HOST` and `SOLR_COLLECTION` to the appropiate server and collection, and execute as shown

```
export SOLR_HOST=192.168.99.100:32080

create-schema.sh
```

You can override the default solr schema name by setting `SOLR_COLLECTION`, but remember to include the additional `v<schema-version-number` at the end, or the loader might refuse to load this.

## Load data

This module loads data from a condensed SDRF in an SCXA experiment to the sc-analytics collection in solr. These routines expect the collection to be created already, and work as an update to the content of the collection.

```
export SOLR_HOST=192.168.99.100:32080
export SOLR_COLLECTION=sc-analytics-v1
export CONDENSED_SDRF_TSV=../scxa-test-experiments/magetab/E-GEOD-106540/E-GEOD-106540.condensed-sdrf.tsv

$ condSdrf2tsvForSCXAJSONFactorsIndex.sh $CONDENSED_SDRF_TSV | jsonGroupByCellID.sh | loadJSONIndexToSolr.sh 
```
