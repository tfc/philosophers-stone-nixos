final: prev:

{
  # This is GNU hello with a patched output line.
  # A minimal example of how to apply a patch on an open source project without
  # forking the whole repo.
  hello-stone = final.callPackage ../projects/hello-stone { };

  message-server = final.callPackage ../projects/message-server/build.nix { };
  message-client = final.callPackage ../projects/message-client/build.nix { };

  # this is a nice example on how to override a dep of a dep of a dep...
  message-server-nopython = prev.message-server.override {
    libpqxx = prev.libpqxx.override {
      postgresql = prev.postgresql.override {
        gssSupport = false;
        libxml2 = prev.libxml2.override {
          icuSupport = false;
          pythonSupport = false;
        };
      };
    };
  };
}
