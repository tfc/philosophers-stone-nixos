{ lib
, rustPlatform
}:
rustPlatform.buildRustPackage {
  name = "message-client";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./src
      ./Cargo.lock
      ./Cargo.toml
    ];
  };
  cargoHash = "sha256-1Lm5iR3uQ43L2H7MulI5eUY8rfUpR8KkOAev7aldJdM=";
}
