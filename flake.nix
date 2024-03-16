{
  description = "Flake Depot.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {

    templates = {
      trivial = {
        path = ./trivial;
        description = "A very basic flake";
      };
    };
    devShell = {
      # Development shell environment for this flake depot.
    };
  };
}
