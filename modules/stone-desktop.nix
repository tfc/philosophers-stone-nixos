{ pkgs, ... }:
{
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager =
    "${pkgs.xfce4-14.xfce4-session}/bin/xfce4-session";
}
