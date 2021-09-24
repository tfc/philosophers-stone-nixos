{ stdenv
, lib
, libpqxx
, boost
, cmake
, gtest
, nix-gitignore
, static ? false
}:
stdenv.mkDerivation {
  name = "message-server";
  version = "1.0";
  src = nix-gitignore.gitignoreSource [] ./.;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ boost libpqxx ];
  checkInputs = [ gtest ];

  cmakeFlags = [
    (lib.optional static "-DBUILD_STATIC=1")
    (lib.optional (!static) "-DENABLE_TESTS=1")
  ];

  makeTarget = "message-server";
  enableParallelBuilding = true;

  doCheck = true;
  checkTarget = "test";

  installPhase = ''
    mkdir -p $out/bin
    cp src/message-server $out/bin/
  '';
}
