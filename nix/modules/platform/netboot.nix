{ modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/netboot/netboot.nix")
  ];
}
