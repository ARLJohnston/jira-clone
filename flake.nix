{
  description = "Jira-clone flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = { self, nixpkgs, pre-commit-hooks }:
    let
      version = builtins.substring 0 1 self.lastModifiedDate;

      supportedSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in {
      devShells = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              go-tools
              go_1_22
              gopls
              gotools
              nixpkgs-fmt
              revive
            ];
          };
        });

      checks = forAllSystems (system: {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            gofmt.enable = true;
            gotest.enable = true;
            govet.enable = true;
            revive.enable = true;
          };
        };
      });

      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in rec {
          bin = pkgs.buildGoModule {
            pname = "jira-clone";
            inherit version;
            src = ./.;
            vendorHash = null;
          };

          docker = pkgs.dockerTools.buildLayeredImage {
            name = "jira-clone";
            tag = "latest";
            config.Cmd = "${bin}/bin/jira";
          };
        });

    };
}
