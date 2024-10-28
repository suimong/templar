{
  description = "Micromamba ready development shell enabled by BuildFSHEnv.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default-linux";
  };

  outputs = { self, nixpkgs, systems, flake-parts, ... }@inputs:
  flake-parts.lib.mkFlake {inherit inputs; } {
    systems = import systems;
    perSystem = {config, self', inputs', pkgs, system, ... }:
      let
        project = rec {
          src = builtins.fromTOML (builtins.readFile ./pyproject.toml);
          name = src.project.name;

        };
      in
      {
        devShells = {
          default = pkgs.mkShellNoCC {
            name = project.name;
            packages = [
              pkgs.pixi
              pkgs.nushell
              pkgs.bashInteractive
            ];
            shellHook = ''
              source_script="$PWD/.repo/.cache/pixi_sourcing.nu"
              pixi shell-hook --shell nushell > $source_script
              nu --execute "source .repo/.cache/pixi_sourcing.nu"
            '';
          };
        };
      };
  };
}
