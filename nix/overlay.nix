final: prev:
let
  sources = import ./sources.nix;
in
{
  # This is GNU hello with a patched output line.
  # A minimal example of how to apply a patch on an open source project without
  # forking the whole repo.
  hello-stone = final.callPackage ../projects/hello-stone { };

  message-server = prev.callPackage ../projects/message-server/build.nix { };
  message-client = prev.callPackage ../projects/message-client/build.nix { };

  # This example demonstrates how to override a dep of a dep to reach the same
  # effect as the example before, without affecting all other packages that
  # need postgres
  message-server-pg13 = prev.message-server.override {
    libpqxx = prev.libpqxx.override {
      postgresql = prev.postgresql_13;
    };
  };
}
