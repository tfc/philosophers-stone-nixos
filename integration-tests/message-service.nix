{ nixosTest }:

let
  testFunction = { pkgs, ... }: {
    name = "run-mdb-service-with-webservice";

    nodes = {
      mdb = _: {
        imports = [ ../modules/message-service.nix ];
      };
    };

    testScript = ''
      def send_message(msg):
          return mdb.succeed(
              f"echo -n {msg} | ${pkgs.nmap}/bin/ncat localhost 1300"
          )

      def check_count(select, nlines):
          output = mdb.succeed(f'su -c "psql -d testdb -tAc \\"{select}\\"" postgres')
          print(output)
          return nlines == len(output.splitlines())

      mdb.start()
      mdb.wait_for_unit("mdb-webservice.service")
      mdb.wait_for_unit("postgresql.service")
      print(mdb.succeed("journalctl -u postgresql.service"))

      mdb.wait_until_succeeds(
          "${pkgs.curl}/bin/curl http://localhost:8000"
      )

      check_count("SELECT * FROM testcounter;", 0)
      send_message("hello")
      check_count("SELECT * FROM testcounter;", 1)

      assert "hello" in mdb.succeed(
          "${pkgs.curl}/bin/curl http://localhost:8000"
      )

      send_message("foobar")
      check_count("SELECT * FROM testcounter;", 2)
      check_count("SELECT * FROM testcounter WHERE content = 'foobar';", 1)
    '';
  };
in
nixosTest testFunction
