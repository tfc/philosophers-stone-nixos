# Philosopher's Stone

What is the philosopher's stone?
Citing [Wikipedia](https://en.wikipedia.org/wiki/Philosopher%27s_stone):

> The philosopher's stone, more properly philosophers' stone or stone of the
> philosophers, is a mythical alchemical substance capable of turning base
> metals such as mercury into gold or silver.

This is very similar to what we do when we transform source code to releasable
images for our customers, while trying to get the process as fast and
reproducible as possible.

In order to create gold, the philosopher's stone is usually mixed with other
ingredients into a container that is then *hermetically sealed* for the duration
of the process.
This is basically exactly what we do when we build software in containers.

# Content

This repository contains:

- some example package definitions in the `projects/` folder
- Composable minimal NixOS example modules for different system configurations
  in the `modules/` folder
- [nixpkgs](https://github.com/nixos/nixpkgs) package database pin and an
  example package database overlay in the `nix/` folder
- example NixOS integration test for our example packages and NixOS service
  definitions in the `integration-tests/` folder
- scripts to demonstrate automatic binary- and source-closure calculation in
  the `scripts/` folder

# Live-Demo Sessions

This repository is used to demonstrate the following scenarios:

- Message Server as typical C++ project
    - nix-shell workflow (day-to-day incremental development)
    - nix-build workflow (consumption/deployment)
- Message Client as typical Rust Project
    - nix-shell workflow
    - nix-build workflow
- GNU Hello Patching
    - create patch from scratch
    - show final derivation
- Show nixpkgs integration
    - `nix repl '<nixpkgs>'`
    - showcase `overlay.nix` additions
- Show how to compose a full system with such packages
    - Go through modules
    - Build & run VMs
    - message server/client Demo
    - RDP Demo
- NixOS integration test (show & run code)
- Demonstrate caching between machines
- Demonstrate closure generation and transfer into offline machine
    - show binary- and source-closure in action

Some demo notes for replaying the more elaborate demo steps out at home:

## Create the offline closure and build in an offline docker image

Create the offline closure of the image.
Please note that `closure.sh` creates a full source- and binary archive of all
build products, while `source-closure.sh` only archives source tarballs and
bootstrap tools.

```sh
$ ./scripts/closure.sh
```

Run podman(/docker) image and import closure from file system

```sh
$ podman run -it --network=none -v /home/user/src/stone:/src nixos/nix
docker-shell # nix-store --import < /src/stone-source.closure
```

Build, Change, Rebuild on the offline machine

```sh
$ nix-build /src --option substituters ""

# ...
```

## Little RDP Demo on NixOS VM

Build and run the RDP demo VM with forwarded ports for SSH (optional) and RDP.

```sh
export QEMU_NET_OPTS="hostfwd=tcp::2221-:22,hostfwd=tcp::3389-:3389"
rm nixos.qcow2
$(nix-build -A run-rdp-server-vm)/bin/run-nixos-vm
```

To connect to the desktop session on the VM via RDP from the host, run:

```sh
nix-shell -p rdesktop --run "rdesktop -u stone -p stone localhost:3389
```
