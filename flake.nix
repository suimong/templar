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
            path = ./trivial;
            description = "A very basic flake";
          };
          py-poetry = {
            path = ./python/poetry;
            description = "A python project managed by Poetry.";
          };
          empty = {
            path = ./empty;
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
