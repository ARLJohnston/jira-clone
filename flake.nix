{
  description = "Jira-clone flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks, gomod2nix }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ gomod2nix.overlays.default ];
          config.allowUnfree = true;
        };

        version = builtins.substring 0 1 self.lastModifiedDate;

        bin = pkgs.buildGoApplication {
          pname = "jira-clone";
          inherit version;
          src = ./.;
          vendorHash = null;
          modules = ./gomod2nix.toml;
        };

        docker = pkgs.dockerTools.buildImage {
          name = "jira-clone";
          tag = "latest";
          created = "now";
          config.Cmd = [ "${bin}/bin/jira" ];
        };

        go-test = pkgs.stdenv.mkDerivation {
          name = "go-test";
          src = ./.;
          doCheck = true;
          nativeBuildInputs = with pkgs; [ docker go_1_22 ];
          checkPhase = ''
            go test ./...
          '';
        };

      in {
        packages = {
          bin = bin;
          docker = docker;
        };

        checks = { inherit go-test; };

        devShell = pkgs.mkShell {
          packages = [ pkgs.gomod2nix ];

          buildInputs = with pkgs; [
            go-tools
            go_1_22
            gopls
            gotools
            nixpkgs-fmt
            revive
            mongodb
            mongodb-compass
            mongodb-tools
          ];
        };

      }));

}
