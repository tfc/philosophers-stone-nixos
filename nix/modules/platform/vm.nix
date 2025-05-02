{ modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
  ];

  virtualisation.memorySize = 1024;
  virtualisation.graphics = true;
}
