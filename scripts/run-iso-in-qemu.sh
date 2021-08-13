#!/usr/bin/env bash

set -euo pipefail

qemu-system-x86_64 \
  -m 512 \
  -machine q35,accel=kvm \
  -cpu host \
  -boot d \
  -cdrom $1

