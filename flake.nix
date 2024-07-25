{
  description = "Jira-clone flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, gomod2nix }:
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
      in {
        packages = {
          bin = bin;

        docker = pkgs.dockerTools.buildImage {
          name = "jira-clone";
          tag = "latest";
          created = "now";
          config.Cmd = [ "${bin}/bin/jira" ];
        };
        };

        devShell = pkgs.mkShell {
          packages = [ pkgs.gomod2nix pkgs.act ];

          buildInputs = with pkgs; [
            go-tools
            go_1_22
            gopls
            gotools
            nixpkgs-fmt
            revive
          ];
        };

      }));

}
