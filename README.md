# Modules for scxa-analytics solr index

Scripts to create and load data into the `scxa-analytics` solr index. Execution of tasks here require that `bin/` directory in the root of this repo is part of your path, and that the following executables are available:

- awk
- jq (1.5)
- curl


## Create schema

To create the schema, set the envronment variable `SOLR_HOST` to the appropiate server, and execute as shown

```
export SOLR_HOST=192.168.99.100:32080

create-scxa-analytics-config-set.sh
create-scxa-analytics-collection.sh
create-scxa-analytics-schema.sh
```

You can override the default solr schema name by setting `SOLR_COLLECTION`, but remember to include the additional `v<schema-version-number>` at the end, or the loader might refuse to load this.

## Load data

This module loads data from a condensed SDRF in an SCXA experiment to the sc-analytics collection in solr. These routines expect the collection to be created already, and work as an update to the content of the collection.

```
export SOLR_HOST=192.168.99.100:32080
export CONDENSED_SDRF_TSV=../scxa-test-experiments/magetab/E-GEOD-106540/E-GEOD-106540.condensed-sdrf.tsv

load_scxa_analytics_index.sh 
```

## Tests

Tests are located in the `tests` directory and use bats. To run them, execute `bash tests/run-tests.sh`. The `tests` folder includes example data in tsv (a condensed SDRF) and in JSON (as it should be produced by the first step that translates the cond. SDRF to JSON).
