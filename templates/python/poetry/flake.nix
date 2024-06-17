{
  description = "Application packaged using poetry2nix";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default-linux";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, systems, poetry2nix }:
    flake-parts.lib.mkFlake {inherit inputs;} 
      {
        systems = import systems;
        perSystem = 
          {
            self',
            config,
            pkgs,
            ...
          }:
          let
            inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryApplication mkPoetryEnv;
          in
          {
            formatter = pkgs.nixfmt;
            packages = rec {
              myapp = mkPoetryApplication { projectDir = ./.; };
              default = myapp;
            };

            devShells.default = pkgs.mkShell {
              # inputsFrom = [ self'.packages.myapp ];
              buildInputs = [
                mkPoetryEnv {
                  projectDir = ./.;
                  preferWheels = true;
                }
              ];
              packages = [ pkgs.poetry ];
            };
          };
      };
}
