{self, ...}: {
  flake.overlays = rec {
    default = redirector;

    redirector = final: _prev: let
      system = final.stdenv.hostPlatform.system;
    in {
      redirector = self.packages.${system}.redirector;
    };
  };
}
