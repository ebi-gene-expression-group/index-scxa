#!/usr/bin/env bash

# Takes a JSONLified condensed SDRF file and creates a sequence of JSON objects
# with the experiment accession, cell ID and the fields we want to display in
# our cell type wheel: organism, organism part and cell type.
# The output of this script is to be merged back with the condensed SDRF JSONL
# so that each document in SCXA analytics has these special fields. This will
# allow us to facet over them with the JSON facet API efficiently.

# Add -s to slurp as an array since we want to map(select(...)) first
jq -s -c \
'
# "Transpose" factors and sample characteristics to a single entry whose key is
# the factor/characteristic name and the value is the factor/characteristic
# value. The two `has` expressions are necessary since keys can’t be null, and
# we would run into that situation because entries have either a factor or a
# characteristic.
# We enclose both in an array so that we can flatten below and keep everything
# wrapped in an array for the group_by operation.
[
map(
  select(has("factor_name")) |
  . as
  {
    cell_id: $cell_id,
    experiment_accession: $experiment_accession,
    factor_name: $factor_name,
    factor_value: $factor_value
  } |
  {
    cell_id,
    experiment_accession,
    ($factor_name): $factor_value
  }
),
map(
  select(has("characteristic_name")) |
  . as
  {
    cell_id: $cell_id,
    experiment_accession: $experiment_accession,
    characteristic_name: $characteristic_name,
    characteristic_value: $characteristic_value
  } |
  {
    cell_id,
    experiment_accession,
    ($characteristic_name): $characteristic_value
  }
)
] |
flatten |
# This creates as many arrays as cell IDs, all belonging to the same cell ID
group_by(.cell_id) |
# Unwrap from the array and turn into a sequence of JSON objects (i.e. arrays)
.[] |
# Merge all objects in each of the arrays into a single object
add |
# Get only the fields we want
{
  key: (.cell_id),
  value: {
    ctw_organism: .organism,
    ctw_organism_part: .organism_part,
    ctw_cell_type: 
      (.["inferred_cell_type_-_ontology_labels"] // 
       .["inferred_cell_type_-_authors_labels"] // 
       .["cell_type"] // .["progenitor_cell_type"]) 
  }
}
' $1 | \
jq -s '. | from_entries'

