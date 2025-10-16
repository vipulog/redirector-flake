{inputs, ...}: {
  imports = [inputs.nci.flakeModule];

  perSystem = {pkgs, ...}: {
    nci = {
      projects.redirector = {
        path = pkgs.runCommand "redirector-src-with-lock" {} ''
          mkdir -p $out
          cp -r ${inputs.redirector}/* $out/
          cp ${./Cargo.lock} $out/Cargo.lock
        '';

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
