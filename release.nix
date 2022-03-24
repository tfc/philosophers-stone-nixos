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
in
{
  pkgs = import ./nix/overlay.nix pkgs pkgs;

  headless-iso = (pkgs.nixos headless-msg-server-config).isoImage;

  run-headless-vm = (pkgs.nixos (headless-msg-server-config ++ [
    "${pkgs.path}/nixos/modules/virtualisation/qemu-vm.nix"
    (_: {
      virtualisation.memorySize = 1024 * 1024;
      virtualisation.graphics = false;
    })
  ])).vm;

  rdp-server-iso =
    (pkgs.nixos (rdp-server-config ++ [ ./modules/iso.nix ])).isoImage;


  run-rdp-server-vm = (pkgs.nixos (rdp-server-config ++ [
    "${pkgs.path}/nixos/modules/virtualisation/qemu-vm.nix"
    (_: {
      virtualisation.memorySize = 1024 * 1024;
      virtualisation.graphics = true;
    })
  ])).vm;

  integration-test = pkgs.callPackage ./integration-tests/message-service.nix { };

  slides = pkgs.callPackage ./doc/slides { };
}
