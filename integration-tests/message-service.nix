{ nixosTest }:

let
  testFunction = { pkgs, ... }: {
    name = "run-mdb-service-with-webservice";

    nodes = {
      mdb = import ../modules/message-service.nix;
    };

    testScript = ''
      from shlex import quote

      def send_message(msg):
          return mdb.succeed(
              f"echo -n {msg} | ${pkgs.nmap}/bin/ncat localhost 1300"
          )

      def sql_query(select):
          cmd = f"psql -d testdb -tAc {quote(select)}"
          output = mdb.succeed(f"su -c {quote(cmd)} postgres")
          return output.splitlines()

      def get_messages(where=""):
          return sql_query(f"SELECT content FROM testcounter {where};")

      mdb.start()
      mdb.wait_for_unit("mdb-webservice.service")
      mdb.wait_for_unit("postgresql.service")

      mdb.wait_until_succeeds(
          "${pkgs.curl}/bin/curl http://localhost:8000"
      )

      assert 0 == len(get_messages())
      send_message("hello")
      assert 1 == len(get_messages())

      assert "hello" in mdb.succeed(
          "${pkgs.curl}/bin/curl http://localhost:8000"
      )

      send_message("foobar")
      assert 2 == len(get_messages())
      assert ["hello", "foobar"] == get_messages()
    '';
  };
in
nixosTest testFunction
