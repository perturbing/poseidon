{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    iohk-nix.url = "github:input-output-hk/iohk-nix";
  };

  outputs = { self, flake-utils, nixpkgs, iohk-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs) {
          inherit system;
        };

        blst = iohk-nix.outputs.pkgs.libblst;

in rec {
        # For `nix build` & `nix run`:
        defaultPackage = pkgs.stdenv.mkDerivation {
          name = "libposeidon";
          src = ./src;
          buildInputs = [ pkgs.gcc blst ];

          # Build phase
          buildPhase = ''
            gcc -fPIC -c poseidon.c -o poseidon.o
            gcc -shared -o libposeidon.so poseidon.o -lblst
          '';

          # Install phase
          installPhase = ''
            mkdir -p $out/lib
            cp libposeidon.so $out/lib/
            mkdir -p $out/include
            cp poseidon.h $out/include/
          '';
        };

        # For `nix develop`:
        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ gcc blst ];
        };
      }
    );
}