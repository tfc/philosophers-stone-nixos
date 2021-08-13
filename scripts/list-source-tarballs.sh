#!/usr/bin/env bash

set -euo pipefail

# Accumulate all output paths that have to do with all our packages in 
# default.nix, which have fixed output hashes, like all the downloads.
nix show-derivation -r $1 \
  | jq -r 'to_entries[] | select(.value.outputs.out.hash != null) | .key'
