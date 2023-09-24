{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let pkgs = (import nixpkgs { system = "x86_64-linux"; }); in
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let pkgs = (import nixpkgs { inherit system; }); in
      {
        devShells.default = pkgs.mkShell { nativeBuildInputs = with pkgs; [ terraform ]; };
        formatter = pkgs.nixpkgs-fmt;
      });
}
