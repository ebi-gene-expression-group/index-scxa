#!/bin/bash
# Sets up the environment and calls [BATS](https://github.com/sstephenson/bats) with provided arguments
source "$(dirname "${BASH_SOURCE[0]}")"/runner-setup.sh

# to check why we cannot write to /tmp
ls -l /

if [ "$#" -eq 0 ]; then
	bats --tap "$(dirname "${BASH_SOURCE[0]}")"
else
	bats "$@"
fi
