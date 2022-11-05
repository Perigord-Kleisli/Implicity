{
  description = "A toy language";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    idris-nix.url = "github:Trouble-Truffle/Idris-nix/e42bc2eeb36b28e3cfb60823030361b4f274646a";
    #idris-nix.url = "path:/home/truff/.local/src/Idris-nix";
  };

  outputs = { self, nixpkgs, flake-utils, idris-nix, ... }:

    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ idris-nix.overlays.${system} ];
        };
        ipkgName = "implicity";
      in
      {
        defaultPackage = with pkgs; build-idris2-package {
          pname = ipkgName;
          version = "0.1";
          src = ./.;
          nativeBuildInputs = [ ];
          extraBuildInputs = [ idris2-nightly ];
          idris2Deps = with pkgs; [ idris2-sop ];
          meta = { };
        };

        devShell = with pkgs; idris-nix.mkShell.${system} {
          packages = [
            idris2-lsp
            rlwrap
          ];

          idris2Deps = [
            idris2-sop
            idris2-elab-util
          ];

          shellHook = ''
          alias idris2="rlwrap idris2"
          '';
        };
      });
}
