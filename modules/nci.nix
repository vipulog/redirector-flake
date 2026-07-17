{
  inputs,
  self,
  ...
}: {
  imports = [inputs.nci.flakeModule];

  perSystem = {pkgs, ...}: let
    redirectorWithLock = pkgs.stdenv.mkDerivation {
      name = "redirector-src";
      src = inputs.redirector;

      installPhase = ''
        mkdir -p $out
        cp -r $src/* $out/
        cp ${self}/Cargo.lock $out/Cargo.lock
      '';
    };
  in {
    nci = {
      projects.redirector = {
        path = redirectorWithLock;

        profiles = {
          release.runTests = false;
        };
      };
    };
  };
}
