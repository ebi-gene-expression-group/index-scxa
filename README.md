[![Docker Repository on Quay](https://quay.io/repository/ebigxa/index-scxa-module/status "Docker Repository on Quay")](https://quay.io/repository/ebigxa/index-scxa-module)

# Module for Single Cell Expression Atlas solr index (v0.1.0-dev)

Scripts to create and load data into the `scxa-*` solr indexes (for analytics and gene2experiment). Execution of tasks here require that `bin/` directory in the root of this repo is part of the path, and that the following executables are available:

- awk
- jq (1.5)
- curl

# `scxa-analytics` index v2

## Create schema

To create the schema, set the environment variable `SOLR_HOST` to the appropriate server, and execute as shown

```
export SOLR_HOST=192.168.99.100:32080

create-scxa-analytics-config-set.sh
create-scxa-analytics-collection.sh
create-scxa-analytics-schema.sh
```

You can override the default solr schema name by setting `SOLR_COLLECTION`, but remember to include the additional `v<schema-version-number>` at the end, or the loader might refuse to load this.

## Load data

This module loads data from a condensed SDRF in an SCXA experiment to the scxa-analytics-v? collection in Solr. These routines expect the collection to be created already, and work as an update to the content of the collection.

```
export SOLR_HOST=192.168.99.100:32080
export CONDENSED_SDRF_TSV=../scxa-test-experiments/magetab/E-GEOD-106540/E-GEOD-106540.condensed-sdrf.tsv

load_scxa_analytics_index.sh
```

## Delete an experiment

In order to delete a particular experiment's analytics solr documents based on its accession from a live index, do:

```
export EXP_ID=desired-exp-identifier
export SOLR_HOST=192.168.99.100:32080

delete_scxa_analytics_index.sh
```

## Tests

Tests are located in the `tests` directory and use bats. To run them, execute `bash tests/run-tests.sh`. The `tests` folder includes example data in tsv (a condensed SDRF) and in JSON (as it should be produced by the first step that translates the cond. SDRF to JSON).

# `scxa-gene2experiment` index v1

## Create schema

To create the schema, set the environment variable `SOLR_HOST` to the appropriate server, and execute as shown

```
export SOLR_HOST=192.168.99.100:32080

create-scxa-gene2experiment-config-set.sh
create-scxa-gene2experiment-collection.sh
create-scxa-gene2experiment-schema.sh
```

You can override the default solr schema name by setting `SOLR_COLLECTION`, but remember to include the additional `v<schema-version-number>` at the end, or the loader might refuse to load this.

## Load data

This module loads data from a matrix markt rows file (set in env var `MATRIX_MARKT_ROWS_GENES_FILE`) containing gene identifiers in the rows for a SCXA experiment to the scxa-gene2experiment-v1 collection in solr. The experiment accession needs to be set in the environment variable `EXP_ID`. These routines expect the collection to be created already, and work as an update to the content of the collection (deduplicating experiment_accession,gene_id tuples).

```
export SOLR_HOST=192.168.99.100:32080
export EXP_ID=E-GEOD-106540
export MATRIX_MARKT_ROWS_GENES_FILE=../path/to/E-GEOD-106540.aggregated_counts.mtx_rows

load_scxa_gene2experiment_index.sh
```

## Delete an experiment

In order to delete a particular experiment's gene2experiment solr documents based on its accession from a live index, do:

```
export EXP_ID=desired-exp-identifier
export SOLR_HOST=192.168.99.100:32080

delete-scxa-gene2experiment-exp-entries.sh
```


## Tests

Tests are located in the `tests` directory and use bats. To run them, execute `bash tests/run-tests.sh`. The `tests` folder includes example data in matrix markt format.

# Container

The container is available for use at quay.io/ebigxa/index-scxa-module at latest or any of the tags after 0.2.0, so it could be used like this for example:

```
docker run -v /local_data:/data \
       -e EXP_ID=<the-accession-of-experiment> \
       -e SOLR_HOST=<solr-host:solr-port> \
       -e MATRIX_MARKT_ROWS_GENES_FILE=<path-inside-container-for-matrixMarkt-file> \
       --entrypoint load_scxa_gene2experiment_index.sh \
       quay.io/ebigxa/index-scxa-module:latest
```

Please note that `MATRIX_MARKT_ROWS_GENES_FILE` needs to make sense with how you mount
data inside the container. You can change entrypoint and env variables given to use the other scripts mentioned above.
