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
        devShells.default =
          let
            #making adhock shell scripts
            myArbetraryCommand = pkgs.writeShellScriptBin "tst" '' ${pkgs.cowsay}/bin/cowsay lalal '';
            drest = pkgs.writeShellScriptBin "drest.sh" "dotnet restore --configfile $NUGET_CONFIG_FILE";

          in
          pkgs.mkShell rec{

            dotnetPkg =
              (with pkgs.dotnetCorePackages; combinePackages [
                sdk_7_0
              ]);

            deps = with pkgs; [
              zlib
              zlib.dev
              openssl
              openssl.dev
              dotnetPkg
              libgit2
            ];

            NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath ([ pkgs.stdenv.cc.cc ] ++ deps);
            NIX_LD = "${pkgs.stdenv.cc.libc_bin}/bin/ld.so";
            nativeBuildInputs = with pkgs;[
              omnisharp-roslyn
              myArbetraryCommand
              drest
            ] ++ deps;

            shellHook = ''
              export LD_LIBRARY_PATH="${pkgs.openssl.out}/lib:$LD_LIBRARY_PATH"
              export LSP_SERVERS="omnisharp,OmniSharp bashls "
              export DOTNET_ROOT = "${dotnetPkg}";
            '';
          };
        formatter = pkgs.nixpkgs-fmt;
      });
}
