final: prev:
let
  sources = import ./sources.nix;
  naersk = final.callPackage sources.naersk {};
in
{
  # This is GNU hello with a patched output line.
  # A minimal example of how to apply a patch on an open source project without
  # forking the whole repo.
  hello-stone = final.callPackage ../projects/hello-stone { };

  message-server = final.callPackage ../projects/message-server/build.nix { };
  message-client = final.callPackage ../projects/message-client/build.nix { inherit naersk; };

  # uncomment this to make postgres 13 the global postgres default lib.
  # run nix-store -q --tree $(nix-build -A pkgs.message-server)
  #     nix-store -q --tree $(nix-build -A pkgs.message-server)
  # to see that they depend on that package now.
  #postgresql = prev.postgresql_13;

  # This example demonstrates how to override a dep of a dep to reach the same
  # effect as the example before, without affecting all other packages that
  # need postgres
  message-server-pg13 = prev.message-server.override {
    libpqxx = prev.libpqxx.override {
      postgresql = prev.postgresql_13;
    };
  };
}
