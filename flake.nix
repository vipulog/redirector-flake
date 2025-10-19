{
  description = "A simple tool to redirect web searches using DuckDuckGo bangs.";

  outputs = inputs @ {flake-parts, ...}: (
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      imports = [./flake-parts.nix];
    }
  );

  nixConfig = {
    extra-substituters = ["https://redirector.cachix.org"];

    extra-trusted-public-keys = [
      "redirector.cachix.org-1:dvngBv4RkdsLLFfbFuxSWJ+Q+y1b126oU3dLizPaQxM="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-parts.url = "github:hercules-ci/flake-parts";

    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    redirector = {
      url = "github:Adolar0042/redirector";
      flake = false;
    };

    nci = {
      url = "github:yusdacra/nix-cargo-integration";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        parts.follows = "flake-parts";
        treefmt.follows = "treefmt-nix";
      };
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
