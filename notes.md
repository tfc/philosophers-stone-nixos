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
