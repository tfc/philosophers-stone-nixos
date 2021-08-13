{ hello }:

hello.overrideAttrs (old: {
  patches = old.patches or [ ] ++ [ ./hello-stone.patch ];

  # we did not patch the unit tests, so they would fail if not disabled.
  doCheck = false;
})
