{
  inputs,
  self,
  ...
}: {
  imports = [inputs.nci.flakeModule];

  perSystem = {pkgs, ...}: let
    cargoLock = builtins.path {
      path = self + "/Cargo.lock";
      name = "Cargo.lock";
    };

    redirectorSrc = pkgs.runCommand "redirector-src" {} ''
      mkdir -p $out
      cp -r ${inputs.redirector}/* $out/
      cp ${cargoLock} $out/Cargo.lock
    '';
  in {
    nci = {
      projects.redirector = {
        path = redirectorSrc;
        profiles.release.runTests = false;
      };
    };
  };
}
