let
  sources = import ./nix/sources.nix;
  pkgs = import ./nix/nixpkgs.nix;

  headless-msg-server-config = { ... }: {
    imports = [
      ./modules/overlay.nix
      ./modules/iso.nix
      ./modules/size-reduction.nix
      ./modules/stone-base.nix
      ./modules/message-service.nix
    ];
  };

  rdp-server-config = { ... }: {
    imports = [
      ./modules/overlay.nix
      ./modules/stone-base.nix
      ./modules/stone-desktop.nix
    ];
  };
in
{
  pkgs = import ./nix/overlay.nix pkgs pkgs;

  headless-iso = (import "${sources.nixpkgs}/nixos/lib/eval-config.nix" {
    modules = [ headless-msg-server-config ];
  }).config.system.build.isoImage;

  run-headless-vm = (import "${sources.nixpkgs}/nixos/lib/eval-config.nix" {
    modules = [
      headless-msg-server-config
      "${sources.nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
      ({ pkgs, ... }: {
        virtualisation.memorySize = "1G";
        virtualisation.graphics = false;
      })
    ];
  }).config.system.build.vm;

  rdp-server-iso = (import "${sources.nixpkgs}/nixos/lib/eval-config.nix" {
    modules = [
      rdp-server-config
      ./modules/iso.nix
    ];
  }).config.system.build.isoImage;


  run-rdp-server-vm = (import "${sources.nixpkgs}/nixos/lib/eval-config.nix" {
    modules = [
      rdp-server-config
      "${sources.nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
      ({ pkgs, ... }: {
        virtualisation.memorySize = "1G";
        virtualisation.graphics = true;
      })
    ];
  }).config.system.build.vm;

  integration-test = import ./integration-tests/message-service.nix { inherit pkgs; };
}
