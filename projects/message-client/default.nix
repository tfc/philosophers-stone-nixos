let
  pkgs = import ../../nix/nixpkgs.nix;
in

pkgs.message-client.overrideAttrs (_: { src = ./.; })
