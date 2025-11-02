{self, ...}: {
  flake.overlays = rec {
    default = redirector;

    redirector = final: _prev: {
      redirector = self.packages.${final.system}.redirector;
    };
  };
}
