{ pkgs, lib, ... }:
let
  authEnv = {
    MDB_HOST = "127.0.0.1";
    MDB_DB   = "testdb";
    MDB_USER = "testuser";
    MDB_PASS = "testpass";
  };
in
{
  networking.firewall.allowedTCPPorts = [ 1300 5000 ];

  services = {
    postgresql = {
      enable = true;
      package = pkgs.postgresql_10;
      enableTCPIP = true;
      authentication = "host  all  all 0.0.0.0/0 md5";
      initialScript = pkgs.writeText "postgres-initScript" ''
        CREATE ROLE ${authEnv.MDB_USER} WITH LOGIN PASSWORD '${authEnv.MDB_PASS}';
        CREATE DATABASE ${authEnv.MDB_DB};
        GRANT ALL PRIVILEGES ON DATABASE ${authEnv.MDB_DB} TO ${authEnv.MDB_USER};
      '';
    };
  };

  systemd.services.mdb-server = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "postgresql.service" ];
    serviceConfig.Restart = "always";
    script = "exec ${pkgs.message-server}/bin/message-server";
    environment = authEnv;
  };

  systemd.services.mdb-webservice = {
    wantedBy = [ "multi-user.target" ];
    after = [ "mdb-server.service" ];
    serviceConfig.Restart = "always";
    script = "exec ${pkgs.message-client-rust}/bin/message-web-client";
    environment = authEnv;
  };
}
