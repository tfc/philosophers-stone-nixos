let
  pkgs = import ./nix/nixpkgs.nix;

  headless-msg-server-config = [
    ./modules/overlay.nix
    ./modules/iso.nix
    ./modules/size-reduction.nix
    ./modules/stone-base.nix
    ./modules/message-service.nix
  ];

  rdp-server-config = [
    ./modules/overlay.nix
    ./modules/stone-base.nix
    ./modules/stone-desktop.nix
  ];

  netboot-image = let
    cfg = pkgs.nixos [
      "${pkgs.path}/nixos/modules/installer/netboot/netboot.nix"
      ./modules/size-reduction.nix
      ./modules/overlay.nix
      ./modules/message-service.nix
      ./modules/stone-base.nix
    ];
  in
    pkgs.symlinkJoin {
      name = "foobar";
      paths = with cfg; [ kernel netbootRamdisk netbootIpxeScript ];
    };
in
{
  pkgs = import ./nix/overlay.nix pkgs pkgs;

  headless-iso = (pkgs.nixos headless-msg-server-config).isoImage;

  run-headless-vm = (pkgs.nixos (headless-msg-server-config ++ [
    "${pkgs.path}/nixos/modules/virtualisation/qemu-vm.nix"
    (_: {
      virtualisation.memorySize = 1024;
      virtualisation.graphics = false;
    })
  ])).vm;

  rdp-server-iso =
    (pkgs.nixos (rdp-server-config ++ [ ./modules/iso.nix ])).isoImage;

  run-rdp-server-vm = (pkgs.nixos (rdp-server-config ++ [
    "${pkgs.path}/nixos/modules/virtualisation/qemu-vm.nix"
    (_: {
      virtualisation.memorySize = 1024;
      virtualisation.graphics = true;
    })
  ])).vm;

  integration-test = pkgs.callPackage ./integration-tests/message-service.nix { };

  inherit netboot-image;

  netboot-script = pkgs.writeShellScript "netboot-in-qemu" ''
    set -euo pipefail

    ${pkgs.qemu}/bin/qemu-system-x86_64 \
      -m 3500 \
      --enable-kvm \
      -cpu host \
      -boot order=n \
      -netdev user,id=net0,tftp=${netboot-image},bootfile=netboot.ipxe \
      -device virtio-net-pci,netdev=net0
  '';

  slides = pkgs.callPackage ./doc/slides { };
}
