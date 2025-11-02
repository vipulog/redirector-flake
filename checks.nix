{
  inputs,
  self,
  ...
}: {
  perSystem = {pkgs, ...}: let
    homeLib = inputs.home-manager.lib;

    testModule = {
      imports = [self.homeModules.redirector];
      services.redirector.enable = true;
      home.username = "test";
      home.homeDirectory = "/home/test";
      home.stateVersion = "25.05";
    };

    testHomeConfig = homeLib.homeManagerConfiguration {
      inherit pkgs;
      modules = [testModule];
    };
  in {
    checks.home-module = testHomeConfig.activationPackage;
  };
}
