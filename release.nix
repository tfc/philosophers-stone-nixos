let
  sources = import ./nix/sources.nix { };
  pkgs = import sources.nixpkgs {
    overlays = [ (import ./nix/overlay.nix) ];
  };

  nixos-configs = import ./nix/nixos-configs.nix { inherit pkgs; };
in
{
  inherit (pkgs)
    hello-stone
    message-server
    message-client
    message-server-pg13
    ;

  inherit (nixos-configs)
    headless-iso
    headless-vm
    netboot-image-folder
    netboot-script
    rdp-server-iso
    rdp-server-vm;

  integration-test = pkgs.testers.runNixOSTest ./integration-tests/message-service.nix;

  slides = pkgs.callPackage ./doc/slides { };
}
