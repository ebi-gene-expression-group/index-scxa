#!/usr/bin/env bash

# Filters out empty string values (for example, not all factors/characteristics have ontology annotations).
# Prints one JSON object per line.
jq -c 'with_entries( select( .value != "" ) )'
