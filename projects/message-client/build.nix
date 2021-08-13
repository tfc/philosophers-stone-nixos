{ python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "message-webclient";
  version = "1.0";

  src = ./.;
  propagatedBuildInputs = with python3Packages; [ flask psycopg2 ];

  # No tests in archive
  doCheck = false;
}
