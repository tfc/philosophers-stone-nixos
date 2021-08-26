let
  pkgs = import ../../nix/nixpkgs.nix;
in

pkgs.message-client-rust.overrideAttrs(_: { src = ./.; })
