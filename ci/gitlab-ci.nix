# This expression discovers all build derivations reachable from the given .nix
# file and assembles a GitLab-compatible object representation which can be
# evaluated into JSON.
# By default, it assumes a release.nix in this script's parent folder, but both
# the root directory and the .nix file can be overriden.
#
# Example:
#
# release.nix:
# {
#   foo = pkgs.callPackage ./build.nix { };
#   bar = import other.nix { inherit pkgs; };
# }
#
# other.nix:
# {
#   tests1 = pkgs.callPackage ./tests1.nix { };
#   tests1 = pkgs.callPackage ./tests2.nix { };
# }
#
# Evaluating this file would yield:
#
# {
#   image = "registry.vpn.cyberus-technology.de:443/infrastructure/nix-docker-image/cyberus-nix:master";
#   before_script = [
#     "git config --global url.https://gitlab-ci-token:\${CI_JOB_TOKEN}@gitlab.vpn.cyberus-technology.de/.insteadOf \"git@gitlab.vpn.cyberus-technology.de:\""
#   ];
#   foo = {
#     "tags" = [ "native-nix" ];
#     "script" = [ "nix-build release.nix -A foo" ];
#   };
#
#   bar.tests1 = {
#     "tags" = [ "native-nix" ];
#     "script" = [ "nix-build release.nix -A bar.tests1" ];
#   };
#
#   bar.tests2 = {
#     "tags" = [ "native-nix" ];
#     "script" = [ "nix-build release.nix -A bar.tests2" ];
#   };
# }
#
# The above structure could then be evaluated into JSON output:
#
# $ NIX_PATH= nix-instantiate --eval --json --strict --read-write-mode nix/gitlab-ci.nix --argstr releaseNixPath ./release.nix -A output
#
# Note that --read-write-mode is necessary when the evaluation needs to create
# store paths for nested derivations.
#
# The resulting output can be used 1:1 as a .gitlab-ci.yml file (YAML being a
# superset of JSON and understood by the pipeline).

{ repositoryRoot ? ../.
, releaseNixPath ? "./release.nix"
}:
let
  # Our input is the imported file containing the derivations to generate build
  # jobs for, e.g., release.nix.
  input' = import (repositoryRoot + "/${releaseNixPath}");

  # Transparently handle inputs with and without arguments
  input = if builtins.isFunction input' then input' { } else input';

  # This helper builds a path string from a current nesting position by joining
  # the current path segment and the attribute using ".". Basically a join
  # operation to deal with the root set.
  pathString = builtins.foldl'
    (current: attr:
      (if current == "" then "" else current + ".") + attr
    ) "";

  isDerivation = x: x ? "type" && x.type == "derivation";

  # Recursively descend into all reachable build attributes
  #   currentPath : current position in the nesting structure
  #   currentSet  : current attribute set
  # For all attributes in the current set:
  #   - If the attribute is a derivation, add it to the list of build attributes
  #   - If the attribute is a nested set, recursively descend into it, extending
  #     the current path by ".<attribute name>"
  discoverBuildAttributes = currentPath: currentSet:
    let
      accumulate = accumList: name:
        let
          value = currentSet."${name}";
          attrsInSet =
            if isDerivation value then [ (pathString (currentPath ++ [ name ])) ]
            else if builtins.typeOf value == "set" then discoverBuildAttributes (currentPath ++ [ name ]) value
            else [ ];
        in
        accumList ++ attrsInSet;
    in
    builtins.foldl' accumulate [ ] (builtins.attrNames currentSet);

  # Discover all build attributes starting from the root
  releaseNixAttributes = discoverBuildAttributes [ ] input;

  # The common build job will need to be tagged as "native-nix" and runs the
  # command "nix-build <nix file> -A <build attribute>".
  defaultBuildJob = attr: {
    "tags" = [ "nix" ];
    "script" = [ "nix-build ${releaseNixPath} -A ${attr}" ];
  };

  # Build the job list: Each job is represented as one element with name
  # denoting the build job's name and value being the job's attributes.
  # This will later be converted to an attribute set using listToAttrs.
  jobs = map (x: { name = "${x}"; value = defaultBuildJob x; }) releaseNixAttributes;
in
{
  # Make the output available as an attribute so nix-instantiate passes the
  # arguments correctly (see https://github.com/NixOS/nix/issues/254)
  output = builtins.listToAttrs jobs;
}
