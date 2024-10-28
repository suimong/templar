{
  description = "Flake Depot.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      systems,
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import systems;
      flake = {
        templates = {
          trivial = {
            path = ./templates/trivial;
            description = "A very basic flake";
          };
          py-poetry = {
            path = ./templates/python/poetry;
            description = "A python project managed by Poetry.";
          };
          micromamba-fhs = rec {
            path = ./templates/python/micromamba-fhs;
            description = "Micromamba enabled through BuildFHSEnv";
            welcomeText = ''
              # ${(import (path + "/flake.nix")).description}
              Please edit the `metadata.nix` file before running `nix develop`.
            '';
          };
          pixi = rec {
            path = ./templates/python/pixi;
            description = (import (path + "/flake.nix")).description;
            welcomeText = ''
              # ${description}
              Please edit the `pyproject.toml` file before running `nix develop`.
            '';
          };
          uv = rec {
            path = ./templates/python/uv;
            description = (import (path + "/flake.nix")).description;
            welcomeText = ''
              # ${description}
              Please edit the `pyproject.toml` file before running `nix develop`.
              
              Please run `nix develop --impure` instead of `nix develop`.
            '';
          };
          empty = {
            path = ./templates/empty;
            description = "An empty flake, useful for non-derivation flakes.";
          };
        };
      };
      perSystem =
        { pkgs, ... }:
        {
          formatter = pkgs.nixfmt-rfc-style;
          devShells.default = pkgs.mkShell {
            # Development shell environment for this flake depot.
            packages = [pkgs.nushellFull pkgs.hello];
            # shellHook = ''
            #   nu
            # '';
          };
        };
    };
}
