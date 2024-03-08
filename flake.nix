# -*- text -*-
{
  description = "MySQL Workbench build env";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs_x86 = import nixpkgs { system = "x86_64-darwin"; };
      pkgs_aarch = import nixpkgs { system = "aarch64-darwin"; };
    in
    {
      formatter = {
        x86_64-darwin = pkgs_x86.nixpkgs-fmt;
        aarch64-darwin = pkgs_aarch.nixpkgs-fmt;
      };
      devShells = {
        x86_64-darwin.default = (import ./shell.nix { pkgs = pkgs_x86; });
        aarch64-darwin.default = (import ./shell.nix { pkgs = pkgs_aarch; });
      };
    };
}
