{
  description = "A toy language";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    idris-nix.url = "github:Trouble-Truffle/Idris-nix";
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
          idris2Deps = [ ];
          meta = { };
        };

        devShell = with pkgs; mkShell {
          packages = with pkgs; [
            idris2-nightly
            idris2-lsp
          ];
          shellHook = with pkgs; ''
            eval "$(idris2 --bash-completion-script idris2)"
            export IDRIS2_PACKAGE_PATH=${idris2-nightly.name}:$IDRIS2_PACKAGE_PATH
          '';
        };
      });
}
