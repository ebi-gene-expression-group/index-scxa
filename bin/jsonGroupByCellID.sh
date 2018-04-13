#!/usr/bin/env bash
jq '[group_by(.cell_id)[]|add|select(length > 0)]' <&0
