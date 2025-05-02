{ pkgs, ... }:
{
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager =
    "${pkgs.xfce.xfce4-session}/bin/xfce4-session";
}
