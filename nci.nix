{inputs, ...}: {
  imports = [inputs.nci.flakeModule];

  perSystem = {pkgs, ...}: let
    redirectorWithLock = pkgs.stdenv.mkDerivation {
      name = "redirector-src";
      src = inputs.redirector;
      installPhase = ''
        mkdir -p $out
        cp -r $src/* $out/
        cp ${./Cargo.lock} $out/Cargo.lock
      '';
    };
  in {
    nci = {
      projects.redirector = {
        path = redirectorWithLock;

        profiles = {
          dev.runTests = false;
          release.runTests = false;
        };
      };

      crates.redirector = {
        depsDrvConfig = {
          mkDerivation = {
            buildInputs = [pkgs.openssl];
            nativeBuildInputs = [pkgs.pkg-config];
          };
        };

        drvConfig = {
          mkDerivation = {
            buildInputs = [pkgs.openssl];
            nativeBuildInputs = [pkgs.pkg-config];
            meta.mainProgram = "redirector";
          };
        };
      };
    };
  };
}
