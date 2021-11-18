#!/usr/bin/env sh

set -euo pipefail

NIX_PATH= nix-instantiate --eval --json --strict --read-write-mode ci/gitlab-ci.nix -A output
