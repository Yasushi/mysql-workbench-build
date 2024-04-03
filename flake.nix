# -*- text -*-
{
  description = "MySQL Workbench build env";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-darwin" "aarch64-darwin" ];
      eachSystem = f: builtins.foldl' (a: b: a // b) { } (map f systems);
    in
    eachSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        rec {
          packages.${system} = {
            python-framework = with pkgs; stdenvNoCC.mkDerivation rec {
              pname = "python-framework";
              version = "3.11.8";
              src = fetchFromGitHub {
                owner = "gregneagle";
                repo = "relocatable-python";
                rev = "67648ffc91aef264f0f8eb2eba14f9ed126f4168";
                hash = "sha256-oVnFscoPuPkAtbaHe24PNqMtngbJ7h8C5wB+FUR7CS0=";
              };
              buildInputs = [ cacert ];
              phases = [ "unpackPhase" "installPhase" ];
              installPhase = ''
                runHook preInstall
                mkdir -p $out
                ./make_relocatable_python_framework.py --python-version=3.11.8 --os-version=11 --destination=$out
                runHook postInstall
              '';
            };

            mysql-connector-cpp = with pkgs; stdenv.mkDerivation rec {
              pname = "mysql-connector-cpp";
              version = "1.1.13";
              src = fetchFromGitHub {
                owner = "mysql";
                repo = "mysql-connector-cpp";
                rev = "1.1.13";
                sha256 = "sha256-4S+pRz/E7uJ/smE2w7TMSpwQsQ5hHY8DLwr7/pilccg=";
              };
              nativeBuildInputs = [ cmake ];
              buildInputs = [ boost mysql80 ];
              cmakeFlags = [ "-DMYSQL_LIB_DIR=${mysql80}/lib" ];
            };
          };

          formatter.${system} = pkgs.nixpkgs-fmt;
          devShells.${system}.default = (import ./shell.nix {
            inherit pkgs; packages = packages.${system};
          });
        });
}
