let
  pkgs = import ./nix/nixpkgs.nix;
in
pkgs.mkShell {
  packages = with pkgs; [
    jq
    niv
    qemu
  ];
}
