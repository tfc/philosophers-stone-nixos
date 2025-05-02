{ pkgs }:

let
  msg-server = [
    ./modules/application/overlay.nix
    ./modules/application/message-service.nix
  ];

  rdp-server = [
    ./modules/application/overlay.nix
    ./modules/application/stone-desktop.nix
  ];

  netboot-platform = [
    ./modules/platform/stone-base.nix
    ./modules/platform/netboot.nix
    ./modules/platform/size-reduction.nix
  ];

  vm-platform = [
    ./modules/platform/stone-base.nix
    ./modules/platform/vm.nix
  ];

  iso-platform = [
    ./modules/platform/stone-base.nix
    ./modules/platform/iso.nix
  ];

  netboot-image-folder = pkgs.symlinkJoin {
    name = "headless-netboot";
    paths = with (pkgs.nixos (msg-server ++ netboot-platform)); [
      kernel
      netbootRamdisk
      netbootIpxeScript
    ];
  };
  cpu-arch = (pkgs.lib.systems.parse.mkSystemFromString pkgs.system).cpu.arch;
in
{
  headless-iso = (pkgs.nixos (msg-server ++ iso-platform)).isoImage;
  headless-vm = (pkgs.nixos (msg-server ++ vm-platform)).vm;
  inherit netboot-image-folder;

  netboot-script = pkgs.writeShellScript "netboot-in-qemu" ''
    set -euo pipefail

    ${pkgs.qemu}/bin/qemu-system-${cpu-arch} \
      -m 3500 \
      --enable-kvm \
      -cpu host \
      -boot order=n \
      -netdev user,id=net0,tftp=${netboot-image-folder},bootfile=netboot.ipxe \
      -device virtio-net-pci,netdev=net0
  '';

  rdp-server-iso = (pkgs.nixos (rdp-server ++ iso-platform)).isoImage;
  rdp-server-vm = (pkgs.nixos (rdp-server ++ vm-platform)).vm;
}
