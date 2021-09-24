{ naersk
, nix-gitignore
}:
naersk.buildPackage
{
  root = nix-gitignore.gitignoreSource [] ./.;
}
