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
  (flake-utils.lib.eachDefaultSystem
  (system:
  let
    pkgs = import nixpkgs {
    inherit system;
    overlays = [
    gomod2nix.overlays.default
    ];
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

  in
  {
      packages = {
        bin = bin;
        docker = docker;
      };


  checks = {
    pre-commit-check = pre-commit-hooks.lib.${system}.run {
      src = ./.;
      hooks = {
        gofmt.enable = true;
        gotest.enable = true;
        govet.enable = true;
        revive.enable = true;
      };
    };
  };

      devShell = pkgs.mkShell {
      #For some insane reason this doesn't work using the `with pkgs;` syntax
        packages = [
          pkgs.gomod2nix
        ];

        buildInputs = [
          pkgs.go-tools
          pkgs.go_1_22
          pkgs.gopls
          pkgs.gotools
          pkgs.nixpkgs-fmt
          pkgs.revive
          pkgs.immudb
        ];
      };

  })
  );

  }
