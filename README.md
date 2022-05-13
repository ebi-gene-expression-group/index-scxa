[![Docker Repository on Quay](https://quay.io/repository/ebigxa/index-scxa-module/status "Docker Repository on Quay")](https://quay.io/repository/ebigxa/index-scxa-module)

# Module for Single Cell Expression Atlas Solr index (v0.6.0)
Scripts to create and load data into the `scxa-*` Solr indexes (for analytics and gene2experiment). Execution of tasks here require that `bin/` directory in the root of this repo is part of the path, and that the following executables are available:

- awk
- jq (1.5)
- curl

Version 0.2.0 was used for loading the August/September 2018 Single Cell Expression Atlas release.

# Authentication

The setup on the CI is made to use authentication with default user and password. The calls assume these settings (solr:SolrRocks), but the user and password can be modified by doing:

```
export SOLR_USER=<new-user>
export SOLR_PASS=<new-pass>
```

To use default auth in a new solr cloud instance, upload `test/security.json` to ZK as shown in the `Setup auth` part of the `run_tests_in_containers.sh`.

In that scheme at least, write operations would require user and password, but read operations should not. Minimal authentication had to be added since Solr 8.x doesn't allow certain operations (like those related to config sets) without authentication.

# `scxa-analytics` index v6
## Create collection
To create the schema, set the environment variable `SOLR_HOST` to the appropriate server, and execute as shown

```bash
export SOLR_HOST=192.168.99.100:32080
```

After doing this you will need to copy the `scatlas.owl` file to *all* your running SolrCloud containers. Set the `SCXA_ONTOLOGY` environment variable to the path of the OWL file as mounted inside the container. Remember to prepend `file://` to the value of the variable, e.g.: `file:///opt/solr/server/solr/scatlas.owl`.
```bash
create-scxa-analytics-config-set.sh
create-scxa-analytics-collection.sh
```

## Enable BioSolr

`scxa-analytics-v5` makes use of the [BioSolr plugin](https://github.com/ebi-gene-expression-group/BioSolr) to perform ontology expansion on document indexing. In order to enable BioSolr, there are 3 options:

### Option 1: Local `.jar` file

Place BioSolr jar (which can be found in the repository's `lib` directory) under `/server/solr/lib/` in your Solr installation directory. This is the oldest option, and has some security issues, but for testing should be fine.

### Option 2: Blob store API

You can use the BioSolr jar as a runtime library stored in the blob store API. In order to enable the use of runtime libraries, you must start your Solr instance with the flag `-Denable.runtime.lib=true`. **This option is now deprecated in solr 8 and will not be available anymore in Solr 9.**

To load the jar, set the environment variable `SOLR_HOST` to the appropriate server, and execute as shown

```bash
export SOLR_HOST=192.168.99.100:32080

create-scxa-analytics-biosolr-lib.sh
```

You can override the default target Solr collection by setting `SOLR_COLLECTION`. You can also provide your own path to the BioSolr jar file by setting `BIOSOLR_JAR_PATH`.

### Option 3: Solr package manager (used in the CI - preferred for production)

Newer versions of solr introduced a new approach, named package manager, to deal with 3rd party JARs and files to be made available to solr. This implies the following steps:

- Create a set of private/public keys (you can run [create-keys-for-tests.sh](tests/create-keys-for-tests.sh) as shown in [run_tests_in_containers.sh](run_tests_in_containers.sh) and keep those).
- Start solr cloud with the `-Denable.packages=true` as done in the CI.
- Upload the public key to solr through Zookeeper (see how the `SIGNING_*` variables are used and the `Upload der to Solr` part, both in [run_tests_in_containers.sh](run_tests_in_containers.sh)).
- Sign the JAR file with the private key and upload it to the solr file store (in our case, BioSolr solr-ontology-update-processor-2.0.0.jar, done by [upload-biosolr-lib.sh](bin/upload-biosolr-lib.sh) in the [analytics.bats](tests/analytics.bats), noting that it is running inside the solr container and that for this purpose, the private key was mounted inside that container on startup).
- Create the package `biosolr` (done as well by [upload-biosolr-lib.sh](bin/upload-biosolr-lib.sh)) in solr pointing to that signed JAR in the solr file store.
- Verify the package (done as well by [upload-biosolr-lib.sh](bin/upload-biosolr-lib.sh)).
- Deploy the package as part of the schema creation (done by [create-scxa-analystics-schema.sh](bin/create-scxa-analytics-schema.sh)).

In the CI, all these steps are done. In some cases, through the API, and in some cases through direct `bin/solr` calls, which might require a container with the same solr version plus the URI to the desired solr server (or execute them inside the same solr server).

Please note that for changes in the Solr version, most likely changes in [BioSolr plugin](https://github.com/ebi-gene-expression-group/BioSolr) will be required, at the very least to point to the newer Solr version, and hence a new JAR will need to be added here. Version 2.0.0 was built against Solr 8.7 (as used in the CI).


## Create schema

```bash
create-scxa-analytics-schema.sh
```

You can override the default target Solr collection name by setting `SOLR_COLLECTION`, but remember to include the additional `v<schema-version-number>` at the end, or the loader might refuse to load this.

## Add suggesters
For the Single Cell Expression Atlas, run the script:

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

## Build suggesters
For the SCXA, to build suggesters with multiple dictionaries on the Solr, run this script:

```bash
build-scxa-analytics-suggestions.sh
```

## Load data
This module loads data from a condensed SDRF in an SCXA experiment to the
`scxa-analytics-v6` collection in Solr. Temporary files are created as part of
this process; by default they are written to `$PWD` but this can be overridden
by exporting the `$WORKDIR` variable. You should make sure that the running
user has write permissions to either the current working directory, or
`$WORKDIR` if it has been set.

```bash
export SOLR_HOST=192.168.99.100:32080
export CONDENSED_SDRF_TSV=../scxa-test-experiments/magetab/E-GEOD-106540/E-GEOD-106540.condensed-sdrf.tsv

load-scxa-analytics.sh
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
This module loads data from a
[Matrix Market](https://math.nist.gov/MatrixMarket/formats.html) rows file (set
in env var `MATRIX_MARKT_ROWS_GENES_FILE`) containing gene identifiers in the
rows for a SCXA experiment to the `scxa-gene2experiment-v1` collection in Solr.
The experiment accession needs to be set in the environment variable `EXP_ID`.
These routines expect the collection to be created already, and work as an
update to the content of the collection (deduplicating
`experiment_accession,gene_id` tuples). Temporary files are created as part of
this process; by default they are written to `$PWD` but this can be overridden
by exporting the `$WORKDIR` variable. You should make sure that the running
user has write permissions to either the current working directory, or
`$WORKDIR` if it has been set.

```bash
export SOLR_HOST=192.168.99.100:32080
export EXP_ID=E-GEOD-106540
export MATRIX_MARKT_ROWS_GENES_FILE=../path/to/E-GEOD-106540.aggregated_counts.mtx_rows

load-scxa-gene2experiment.sh
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
