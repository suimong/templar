{
  description = "A generic python project managed by uv.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default-linux";
  };

  outputs = { self, nixpkgs, systems, flake-parts, }@inputs:
  flake-parts.lib.mkFlake {inherit inputs; } {
    systems = import systems;
    perSystem = {config, self', inputs', pkgs, lib, system, ... }:
      let
        python_ld_lib_path = pkgs.lib.makeLibraryPath (with pkgs; [
          zlib
          zstd
          stdenv.cc.cc
          curl
          openssl
          attr
          libssh
          bzip2
          libxml2
          acl
          libsodium
          util-linux
          xz
        ]);
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
              pkgs.python3
              pkgs.uv
            ];
            VIRTUAL_ENV_DISABLE_PROMPT = true;
            UV_PYTHON_DOWNLOADS = "never";
            NIX_LD = lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
            NIX_LD_LIBRARY_PATH = python_ld_lib_path;
            shellHook =''
              uv venv .venv
              exec nu --execute "overlay use .venv/bin/activate.nu"
            '';
          };
        };
      };
  };
}
