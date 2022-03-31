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

  boot.kernelParams = [ "boot.panic_on_fail" ];

  # Don't allow emergency mode, because we don't have a console.
  systemd.enableEmergencyMode = false;

  # We have no persistent file systems.
  boot.initrd.checkJournalingFS = false;

  # Additional minimization.
  environment.defaultPackages = [ ];
  boot.enableContainers = false;
  security.sudo.enable = false;
  xdg.autostart.enable = false;
  xdg.icons.enable = false;
  xdg.menus.enable = false;
  xdg.mime.enable = false;
  xdg.sounds.enable = false;
  programs.command-not-found.enable = false;
  system.fsPackages = lib.mkForce [ ];
}
