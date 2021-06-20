#!/usr/bin/env bash

# Filters out empty string values (for example, not all factors/characteristics have ontology annotations).
jq 'with_entries( select( .value != "" ) )'
