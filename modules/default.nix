{
  inputs,
  self,
  ...
}: {
  imports = [
    ./pre-commit.nix
    ./treefmt.nix
    ./shell.nix
    ./packages
    ./checks.nix
    ./overlays.nix
    ./nci.nix
    ./home-module.nix
  ];

  perSystem = {system, ...}: {
    _module.args = {
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [self.overlays.redirector];
      };
    };
  };
}
