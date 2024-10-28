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
        metadata = import ./metadata.nix;
        mamba = rec {
          root_prefix = builtins.toString ./.repo/.mamba;
          rcfile = builtins.toString ./.repo/.mambarc;
          getPrefix = {name, root ? root_prefix}: "${root}/envs/${name}";
          env = rec {
            name = metadata.mamba_env_name;
            prefix = getPrefix {name = name;};
          };
        };
        fhsEnvDrv = pkgs.buildFHSEnv {
          name = "mamba-fhs";
          targetPkgs = pkgs: [
            pkgs.bashInteractive
            pkgs.micromamba
            pkgs.nushell
          ];
          runScript = "nu";
          # ref: https://github.com/ereduled/kickstart-python/blob/6ca6244e030bed39c9f99408037336297f73a81c/kickstart-python/flake.nix
          profile = ''
          set -e

          export MAMBA_ROOT_PREFIX=${mamba.root_prefix}
          export MAMBARC=${mamba.rcfile}

          if ! [ -d "${mamba.env.prefix}" ]; then
            ## 1. Create an ephemeral conda environment that contains conda-lock
            ## ...micromamba supports conda-lock's "unified" lock file format
            
            echo "Creating micromamba environment: ${mamba.env.name}";
            micromamba create --yes -n ${mamba.env.name}
            eval "$(micromamba shell hook --shell=posix)"
          fi
          
          eval "$(micromamba shell hook --shell=posix)"
          micromamba activate ${mamba.env.name}
          set +e
          '';
        };
      in
      {
        devShells = rec {
          fhs = fhsEnvDrv.env.overrideAttrs {
            name = "mamba-fhs";
          };
          default = fhs;
        };
      };
  };
}
