# Typical Demos to Show

- Message Server as typical C++ project
  - nix-shell workflow
  - nix-build workflow
- Message Client as typical Python Project
  - nix-shell workflow
  - nix-build workflow
- GNU Hello Patching
  - create patch from scratch
  - show final derivation
- Show nixpkgs integration
  - `nix repl '<nixpkgs>'`
  - introduce overlay.nix
- Show how to compose a full system w/ such packages
  - Go through modules
  - Build & run VMs (ISOs take too long)
  - message server/client Demo, RDP Demo
- NixOS integration test (show & run code)
- Demonstrate caching between machines
- Demonstrate closure generation and transfer into offline podman image
  - show binary, show source closures

# Create a patched version of GNU hello

```sh
nix-shell '<nixpkgs>' -A pkgs.hello --run unpackPhase
cp -r hello-2.10 hello-stone

cd hello-stone
# perform your changes
cd ..

diff -ru hello-2.10 hello-stone > hello-stone.patch
```

# Create the offline closure and build in an offline docker image

1. Create the offline closure of the image

```sh
$ ./scripts/closure.sh
```

2. Run docker image and import closure from file system

```sh
$ podman run -it --network=none -v /home/user/src/stone:/src nixos/nix
docker-shell # nix-store --import < /src/stone-source.closure
```

3. Build, Change, Rebuild

```sh
$ nix-build /src --option substituters ""

# ...
```

# Run Qemu VM and demonstrate RDP

```sh
export QEMU_NET_OPTS="hostfwd=tcp::2221-:22,hostfwd=tcp::3389-:3389"
rm nixos.qcow2
$(nix-build -A run-rdp-server-vm)/bin/run-nixos-vm
```

on the host, run:

```sh
nix-shell -p rdesktop --run "rdesktop -u stone -p stone localhost:3389
```
