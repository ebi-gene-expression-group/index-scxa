[![Docker Repository on Quay](https://quay.io/repository/ebigxa/index-scxa-module/status "Docker Repository on Quay")](https://quay.io/repository/ebigxa/index-scxa-module)

# Module for Single Cell Expression Atlas Solr index (v0.5.0)

Scripts to create and load data into the `scxa-*` Solr indexes (for analytics and gene2experiment). Execution of tasks here require that `bin/` directory in the root of this repo is part of the path, and that the following executables are available:

- awk
- jq (1.5)
- curl

Version 0.2.0 was used for loading the August/September 2018 Single Cell Expression Atlas release.

# `scxa-analytics` index v5

## Create collection
To create the schema, set the environment variable `SOLR_HOST` to the appropriate server, and execute as shown

```bash
export SOLR_HOST=192.168.99.100:32080

create-scxa-analytics-config-set.sh
create-scxa-analytics-collection.sh
```

## Enable BioSolr
`scxa-analytics-v5` makes use of the [BioSolr plugin](https://github.com/ebi-gene-expression-group/BioSolr) to perform ontology expansion on document indexing. In order to enable BioSolr, there are 2 options:

### Option 1: Local `.jar` file
Place BioSolr jar (which can be found in the repository's `lib` directory) under `/server/solr/lib/` in your Solr installation directory.

### Option 2: Blob store API
You can use the BioSolr jar as a runtime library stored in the blob store API. In order to enable the use of runtime libraries, you must start your Solr instance with the flag `-Denable.runtime.lib=true`.

To load the jar, set the environment variable `SOLR_HOST` to the appropriate server, and execute as shown

```bash
export SOLR_HOST=192.168.99.100:32080

create-scxa-analytics-biosolr-lib.sh
```

You can override the default target Solr collection by setting `SOLR_COLLECTION`. You can also provide your own path to the BioSolr jar file by setting `BIOSOLR_JAR_PATH`.

## Create schema
```bash
create-scxa-analytics-schema.sh
```

You can override the default target Solr collection name by setting `SOLR_COLLECTION`, but remember to include the additional `v<schema-version-number>` at the end, or the loader might refuse to load this.

## Add suggesters

For Single Cell Expression Atlas run:
```bash
create-scxa-analytics-suggesters.sh
```

## Suggesters Dictionary Implementation

We are using multiple dictionaries (dictionaryImpl) for a single `SuggestComponent` to fetch various suggestions.

#### Dictionary Implementations: 

   - ontologyAnnotationSuggester
   - ontologyAnnotationAncestorSuggester
   - ontologyAnnotationParentSuggester
   - ontologyAnnotationSynonymSuggester
   - ontologyAnnotationChildSuggester

## Load data
This module loads data from a condensed SDRF in an SCXA experiment to the scxa-analytics-v? collection in Solr. These routines expect the collection to be created already, and work as an update to the content of the collection.

```bash
export SOLR_HOST=192.168.99.100:32080
export CONDENSED_SDRF_TSV=../scxa-test-experiments/magetab/E-GEOD-106540/E-GEOD-106540.condensed-sdrf.tsv

load_scxa_analytics_index.sh
```

## Delete an experiment
In order to delete a particular experiment's analytics Solr documents based on its accession from a live index, do:

```bash
export EXP_ID=desired-exp-identifier
export SOLR_HOST=192.168.99.100:32080

delete_scxa_analytics_index.sh
```

## Tests
Tests are located in the `tests` directory and require Docker to run. To run them, execute `run_tests_in_containers.sh`. The `tests` folder includes example data in TSV (a condensed SDRF) and in JSON (as it should be produced by the first step that translates the cond. SDRF to JSON).

# `scxa-gene2experiment` index v1

## Create schema
To create the schema, set the environment variable `SOLR_HOST` to the appropriate server, and execute as shown

```bash
export SOLR_HOST=192.168.99.100:32080

create-scxa-gene2experiment-config-set.sh
create-scxa-gene2experiment-collection.sh
create-scxa-gene2experiment-schema.sh
```

You can override the default target Solr collection name by setting `SOLR_COLLECTION`, but remember to include the additional `v<schema-version-number>` at the end, or the loader might refuse to load this.

## Load data
This module loads data from a [Matrix Market](https://math.nist.gov/MatrixMarket/formats.html) rows file (set in env var `MATRIX_MARKT_ROWS_GENES_FILE`) containing gene identifiers in the rows for a SCXA experiment to the scxa-gene2experiment-v1 collection in Solr. The experiment accession needs to be set in the environment variable `EXP_ID`. These routines expect the collection to be created already, and work as an update to the content of the collection (deduplicating experiment_accession,gene_id tuples).

```bash
export SOLR_HOST=192.168.99.100:32080
export EXP_ID=E-GEOD-106540
export MATRIX_MARKT_ROWS_GENES_FILE=../path/to/E-GEOD-106540.aggregated_counts.mtx_rows

load_scxa_gene2experiment_index.sh
```

## Delete an experiment
In order to delete a particular experiment's gene2experiment Solr documents based on its accession from a live index, do:

```bash
export EXP_ID=desired-exp-identifier
export SOLR_HOST=192.168.99.100:32080

delete-scxa-gene2experiment-exp-entries.sh
```


## Tests
Tests are located in the `tests` directory and require Docker to run. To run them, execute `run_tests_in_containers.sh`. The `tests` folder includes example data in Matrix Market format.

# Container

The container is available for use at quay.io/ebigxa/index-scxa-module at latest or any of the tags after 0.2.0, so it could be used like this:

```bash
docker run -v /local_data:/data \
       -e EXP_ID=<the-accession-of-experiment> \
       -e SOLR_HOST=<solr-host:solr-port> \
       -e MATRIX_MARKT_ROWS_GENES_FILE=<path-inside-container-for-matrixMarkt-file> \
       --entrypoint load_scxa_gene2experiment_index.sh \
       quay.io/ebigxa/index-scxa-module:latest
```

Please note that `MATRIX_MARKT_ROWS_GENES_FILE` needs to make sense with how you mount
data inside the container. You can change entrypoint and env variables given to use the other scripts mentioned above.
