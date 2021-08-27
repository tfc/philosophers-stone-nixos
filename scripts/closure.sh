#!/usr/bin/env bash

set -euo pipefail

echo $PWD

evaluationPaths=$(nix-instantiate \
  --eval \
  --strict \
  --json \
  -E "builtins.map builtins.toString (builtins.attrValues (import ./nix/sources.nix {}))" \
  | jq -r .[])

echo eval paths
echo $evaluationPaths

buildClosurePaths=$(nix-store -qR --include-outputs $(nix-instantiate default.nix))

echo build closure paths
echo $buildClosurePaths

echo build closure size
du -sm $evaluationPaths $buildClosurePaths | sort -n

nix-store --export $evaluationPaths $buildClosurePaths > stone.closure
