#!/usr/bin/env bash

set -euo pipefail

defaultNixFile=default.nix
sourcesNixFile=nix/sources.nix

if [[ ! -f $defaultNixFile ]] || [[ ! -f $sourcesNixFile ]]; then
  echo "Run this script from the philosopher's stone repo root path."
  exit 1
fi

# nix does not track evaluation-time paths as dependencies of a derivation.
# Anticipating which paths are going to be evaluated is easy:
evaluationPaths=$(nix-instantiate \
  --eval \
  --strict \
  -E "builtins.map builtins.toString (builtins.attrValues (import ./nix/sources.nix {}))" \
  | jq -r .[])

# Accumulate all output paths that have to do with all our packages in 
# default.nix, which have fixed output hashes, like all the downloads.
sourceClosurePaths=$(./scripts/list-source-tarballs.sh $(nix-instantiate default.nix) \
  | xargs nix-store -r)

echo source closure sizes
du -sm $evaluationPaths $sourceClosurePaths | sort -n

nix-store --export $evaluationPaths $sourceClosurePaths > stone-sources.closure
