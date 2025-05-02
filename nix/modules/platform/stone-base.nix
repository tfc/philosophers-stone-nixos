# This module adds some standard tools for playing around in a demo
# and also disables security measures for demo reasons.
# a real product wouldn't disable the security things, of course.
{ lib, pkgs, ... }:

let
  inherit (lib) mkDefault mkForce;
in

{
  users.users.stone = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "stone";
  };
  users.users.root.initialPassword = "stone";

  environment.systemPackages = with pkgs; [
    mkpasswd # for generating password files

    # Some text editors.
    vim

    # network tools
    rsync
    socat
    screen
    nmap

    # Tools to create / manipulate filesystems.
    dosfstools

    # Some compression/archiver tools.
    unzip
    zip

    hello-stone
  ];

  security.sudo = {
    enable = mkDefault true;
    wheelNeedsPassword = mkForce false;
  };

  services.getty.autologinUser = "stone";
  services.getty.helpLine = ''
    Hello, this is the Philosopher's Stone NixOS image.

    The "stone" and "root" accounts both have the password "stone".
    OpenSSH daemon is running.
  '';

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PermitEmptyPasswords = "yes";
    };
  };
  security.pam.services.sshd.allowNullPassword = true;

  networking.firewall.enable = false;
  networking.useDHCP = true;
}
