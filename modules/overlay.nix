{ ... }:

{
  nixpkgs.overlays = [ (import ../nix/overlay.nix) ];
}
