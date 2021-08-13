# this importable module represents a collection of things to do in order to
# minimize system size.
{ modulesPath, lib, ... }:

{
  imports = [
    # removes documentation etc.
    "${modulesPath}/profiles/minimal.nix"
  ];

  # provided by modules/config/no-x-libs.nix
  environment.noXlibs = true;

  # inspired by modules/profiles/headless.nix
  boot.vesa = false;
  boot.loader.grub.splashImage = null;

  security.polkit.enable = lib.mkForce false;
}
