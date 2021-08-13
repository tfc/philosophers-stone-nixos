final: prev:

{
  # This is GNU hello with a patched output line.
  # A minimal example of how to apply a patch on an open source project without
  # forking the whole repo.
  hello-stone = final.callPackage ../projects/hello-stone { };

  message-server = final.callPackage ../projects/message-server/build.nix { };
  message-client = final.callPackage ../projects/message-client/build.nix { };

  message-server-nopython = prev.message-server.override {
    libpqxx = prev.libpqxx.override {
      postgresql = prev.postgresql.override {
        libxml2 = prev.libxml2.override {
          pythonSupport = false;
        };
      };
    };
  };
}
