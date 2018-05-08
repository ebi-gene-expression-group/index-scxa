#!/usr/bin/env bash

# Explanations for model 4:
# Group by makes arrays of entries grouped by .cell_id and .experiment_accession
# .[] iterates one by one over the arrays created, so that
# map([ .[] ] | .... ) is operating over a set of entries that all have the same .cell_id and .experiment_accession
# inside map, .[] is listing all the elements within that cell_id/experiment accession group
# and then reduce is going through all key-values (so "cell_id": "SRR626171" and "characteristics_cell_type": [ "type1" ] would be key-value pairs)
# and aggregating them -- .[$key] |= ( . + $o[$key] | unique ) -- uniquely if they are not either cell_type nor exp_accession ( see if ). 
# This model relies on being passed an array of json objects each representing a line in the the condensed sdr file, where all fields are arrays
# besides "cell_id" and "experiment_accession".

# (4)
jq '[group_by([.cell_id, .experiment_accession])] | .[] | map([ .[] ] | reduce .[] as  $o ({}; reduce ($o|keys)[] as $key (.; if $key=="cell_id" or $key=="experiment_accession" then .[$key] = $o[$key] else .[$key] |= ( . + $o[$key] | unique ) end )) | select(length > 0) )'

# Given the functional complexity of jq, I'm leaving the thought process that is not captured by the version control below.

# (4) evolved from (3) to avoid duplication of entries on "factors" and "characteristics"
# (3)
# jq '[group_by([.cell_id, .experiment_accession])] | .[] | map([ .[] ] | reduce .[] as  $o ({}; reduce ($o|keys)[] as $key (.; if $key=="cell_id" or $key=="experiment_accession" then .[$key] = $o[$key] else .[$key] += $o[$key] end ))  )' <&0

# (3) evolved from (2) to avoid cell_id and experiment_accession to be concatenated as the other fields
# (2)
# jq [group_by([.cell_id, .experiment_accession])] | .[] | map([ .[] ] | reduce .[] as  $o ({}; reduce ($o|keys)[] as $key (.; .[$key] += $o[$key] ))   ) 

# (2) evolved from (1) to allow for all fields, and not only "factors" and "characteristics", are aggregated if they have multiple values (here only the last value was being used.
# (1)
# jq '[group_by([.cell_id, .experiment_accession])] | .[] | map([ .[] + { "factors": (map(.factors) | del(.[] | nulls)), "characteristics": (map(.characteristics) | del(.[] | nulls)) }] | add)' <&0

# (1) evolved from the previous version in the version control.




# map([ .[] + : put all elements of the array
#       { "factors": (map(.factors) | del(.[] | nulls)), "characteristics": (map(.characteristics) | del(.[] | nulls)) }] : and redefine characteristics and factors to put all different elements together, removing nulls.
# add : join together per cell_id and experiment accession.
# [group_by([.cell_id, .experiment_accession])] | .[] | map([ .[] ] | reduce .[] as  $o ({}; reduce ($o|keys)[] as $key (.; .[$key] += $o[$key] ))   ) 
# jq '[group_by([.cell_id, .experiment_accession])] | .[] | map([ .[] + { "factors": (map(.factors) | del(.[] | nulls)), "characteristics": (map(.characteristics) | del(.[] | nulls)) }] | add)' <&0

# [group_by([.cell_id, .experiment_accession])] : produced an array for each combination of cell id and experiment accession, so we have an array or arrays.
