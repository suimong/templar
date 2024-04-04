{
  description = "Flake Depot.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, systems }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import systems;
      flake = {
        templates = {
          trivial = {
            path = ./trivial;
            description = "A very basic flake";
          };
        };
      };
      perSystem = { pkgs, ... }: {
        formatter = pkgs.nixfmt-rfc-style;
        devShells = {
          # Development shell environment for this flake depot.
        };
      };
    };
}
