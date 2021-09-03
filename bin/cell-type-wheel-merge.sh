#!/usr/bin/env bash

# Merges an object in $2 to an object in $1 if they have the same value in  the
# field cell_id

# Not sure this is entirely correct
# From https://stackoverflow.com/questions/39830426/join-two-json-files-based-on-common-key-with-jq-utility-or-alternative-way-from

jq \
-nc --slurpfile ctw $1 \
'
def hashJoin(a1; a2; key):
  def akey: key | if type == "string" then . else tojson end;
  def wrap: { (akey) : . } ;
  # hash phase:
  (reduce a1[] as $o ({};  . + ($o | wrap ))) as $h1
  | (reduce a2[] as $o
      ( {};
        ($o|akey) as $v
        | if $h1[$v] then . + { ($v): $o } else . end )) as $h2
  # join phase:
  | reduce ($h2|keys[]) as $key
      ([];  . + [ $h1[$key] + $h2[$key] ] ) ;

hashJoin( $ctw; $cond; .cell_id)[]
'
--slurpfile cond $2
