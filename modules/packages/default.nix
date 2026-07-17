{inputs, ...}: {
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    packages = rec {
      default = redirector;
      redirector = config.nci.outputs.redirector.packages.release;

      generate-lockfile = pkgs.writeShellApplication {
        name = "generate-lockfile";
        runtimeInputs = with pkgs; [coreutils tomlq semver-tool cargo];
        runtimeEnv.REDIRECTOR_SRC = inputs.redirector;
        text = builtins.readFile ./generate-lockfile.sh;
      };
    };
  };
}
