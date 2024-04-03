# -*- text -*-
{ pkgs ? import <nixpkgs> { }
, packages
}:

with pkgs;
let
  helper = stdenv.mkDerivation {
    name = "helper functions";
    phases = [ "fixupPhase" ];
    setupHook = writeText "setup-helper-functions" ''
      create3rdPartyDirectories() {
        mkdir -p $sourceRoot/3rd-party-ce/{bin,include,lib/mysql,Python} $sourceRoot/3rd-party-se/lib/mysql
      }
      copy3rdPartyLib() {
        cp -n \
          ${glib.out}/lib/libglib-2.0.0.dylib \
          ${cairo}/lib/libcairo.2.dylib \
          ${glib.out}/lib/libgmodule-2.0.0.dylib \
          ${vsqlite}/lib/libvsqlitepp.3.dylib \
          ${openssl.out}/lib/libssl.3.dylib \
          ${openssl.out}/lib/libcrypto.3.dylib \
          ${libpng}/lib/libpng16.16.dylib \
          ${pixman}/lib/libpixman-1.0.dylib \
          $sourceRoot/3rd-party-ce/lib
        cp -n ${libssh}/lib/libssh.4.9.6.dylib $sourceRoot/3rd-party-ce/lib/libssh.dylib
        cp -n ${gdal}/lib/libgdal.34.3.8.4.dylib $sourceRoot/3rd-party-ce/lib/libgdal.dylib
        cp -n ${libzip}/lib/libzip.5.5.dylib $sourceRoot/3rd-party-ce/lib/libzip.dylib
        cp -n ${mysql80}/lib/libmysqlclient.21.dylib $sourceRoot/3rd-party-ce/lib/mysql/libmysqlclient.dylib
        cp -n ${sqlite.out}/lib/libsqlite3.0.dylib $sourceRoot/3rd-party-ce/lib/libsqlite3.dylib
        cp -n ${sqlite.out}/lib/libsqlite3.0.dylib $sourceRoot/3rd-party-ce/lib/libsqlite3.so
        cp -n ${darwin.libiconv}/lib/libiconv.2.4.0.dylib $sourceRoot/3rd-party-ce/lib/libiconv.2.dylib
        cp -n ${zstd.out}/lib/libzstd.1.5.5.dylib $sourceRoot/3rd-party-ce/lib/libzstd.1.dylib
        cp -n ${packages.mysql-connector-cpp}/lib/libmysqlcppconn.7.1.1.13.dylib $sourceRoot/3rd-party-ce/lib/libmysqlcppconn.dylib
        cp -n ${antlr4_11.runtime.cpp}/lib/libantlr4-runtime.4.11.1.dylib $sourceRoot/3rd-party-ce/lib/libantlr4-runtime.dylib
        cp -n ${antlr4_11.jarLocation} $sourceRoot/3rd-party-ce/bin/antlr-4.11.1-complete.jar

        cp -R ${packages.python-framework}/Python.framework $sourceRoot/3rd-party-ce/Python/

        chmod -R u+w \
          $sourceRoot/3rd-party-ce/bin/*.jar \
          $sourceRoot/3rd-party-ce/lib/{,mysql/}*.dylib \
          $sourceRoot/3rd-party-ce/lib/*.so \
          $sourceRoot/3rd-party-ce/Python
        $sourceRoot/build/fixup_dylib_paths.sh \
          $sourceRoot/3rd-party-ce/lib/{,mysql/}*.dylib \
          $sourceRoot/3rd-party-ce/lib/*.so
      }
      symlink3rdPartyIncudes() {
        ln -s ${glib.dev}/include/glib-2.0 $sourceRoot/3rd-party-ce/include/
        ln -s ${glib.out}/lib/glib-2.0 $sourceRoot/3rd-party-ce/lib/
        ln -s ${boost180.dev}/include/boost $sourceRoot/3rd-party-ce/include/
        ln -s ${rapidjson}/include/rapidjson $sourceRoot/3rd-party-ce/include/
        ln -s ${cairo.dev}/include $sourceRoot/3rd-party-ce/include/cairo
        ln -s ${libssh}/include/libssh $sourceRoot/3rd-party-ce/include/
        ln -s ${vsqlite}/include/sqlite $sourceRoot/3rd-party-ce/include/
        ln -s ${gdal}/include/*.h $sourceRoot/3rd-party-ce/include/
        ln -s ${libzip.dev}/include/zip*.h $sourceRoot/3rd-party-ce/include/
        ln -s ${unixODBC}/include/{sql*,unixodbc}.h $sourceRoot/3rd-party-ce/include/
        ln -s ${mysql80}/include/mysql $sourceRoot/3rd-party-ce/include/
        ln -s ${antlr4_11.runtime.cpp.dev}/include/antlr4-runtime $sourceRoot/3rd-party-ce/include/
        ln -s ${packages.mysql-connector-cpp}/include/* $sourceRoot/3rd-party-ce/include/
      }
      fixJavaPath() {
        sed -i.bak -e 's! java -jar! ${zulu17}/bin/java -jar!' $sourceRoot/library/parsers/grammars/build-parsers-mac
      }
      fixSwigPath() {
        sed -i.bak -e 's!/usr/local/bin/swig !${swig}/bin/swig ! ' $sourceRoot/MySQLWorkbench.xcodeproj/project.pbxproj
      }

      postUnpackHooks+=(create3rdPartyDirectories copy3rdPartyLib symlink3rdPartyIncudes fixJavaPath fixSwigPath)
    '';
  };
in
mkShell {
  packages = [
    mysql80
    glib
    boost180
    rapidjson
    cairo
    libssh
    vsqlite
    gdal
    libzip
    unixODBC
    openssl
    libpng
    pixman
    sqlite
    darwin.libiconv
    zstd.dev
    antlr4_11
    antlr4_11.runtime.cpp
    zulu17
    packages.mysql-connector-cpp
    packages.python-framework
  ];

  src = fetchFromGitHub {
    owner = "mysql";
    repo = "mysql-workbench";
    rev = "8.0";
    sha256 = "sha256-Lwl2jiay/T1H4hfuPF3roYiJqcK+J1YME/tiNjB49B8";
  };

  patches = [ ./fixup_python_paths.patch ./clipToBounds.patch ./xcodeproj.patch ];

  buildInputs = [
    gnused
    helper
    swig
  ];
}
