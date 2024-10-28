{
  description = "Pixi based Python development environment.";

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
          pixi_sourcing_script_rel_path = ".repo/.cache/pixi_sourcing.nu";
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
              source_script="$PWD/${project.pixi_sourcing_script_rel_path}"

              echo "Initializing pixi environment..."
              pixi shell-hook --shell nushell > $source_script

              mv gitignore .gitignore
              mv gitattributes .gitattributes
              exec nu --execute "source ${project.pixi_sourcing_script_rel_path}"
            '';
          };
        };
      };
  };
}
