{
  lib,
  inputs,
  moduleWithSystem,
  ...
}: {
  imports = [inputs.home-manager.flakeModules.home-manager];

  flake.homeModules = rec {
    default = redirector;

    redirector = moduleWithSystem (
      {pkgs, ...}: {config, ...}: let
        cfg = config.services.redirector;
        configFormat = pkgs.formats.toml {};
        configFile = configFormat.generate "config.toml" cfg.settings;
      in {
        options.services.redirector = {
          enable = lib.mkEnableOption "redirector";

          package = lib.mkOption {
            type = lib.types.package;
            default = pkgs.redirector;
          };

          settings = lib.mkOption {
            type = configFormat.type;
            default = {};

            example = lib.literalExpression ''
              {
                port = 3000;
                bangs_url = "https://duckduckgo.com/bang.js";
                default_search = "https://www.qwant.com/?q={}";
                bangs = [
                  {
                    trigger = "gh";
                    url_template = "https://github.com/search?q={{{s}}}";
                    short_name = "GitHub";
                    category = "Tech";
                  }
                ];
              }
            '';
          };
        };

        config = lib.mkIf cfg.enable {
          nix = {
            package = lib.mkDefault pkgs.nix;

            settings = {
              substituters = ["https://redirector.cachix.org"];

              extra-trusted-public-keys = [
                "redirector.cachix.org-1:lx9grKUxrkiq/H1qkIV/oEgRB9SmYGD2Yg37fHs6TlE="
              ];
            };
          };

          home = {
            file.".config/redirector/config.toml".source = configFile;
            packages = [cfg.package];
          };

          systemd.user.services.redirector = {
            Unit = {
              Description = "redirector";
              After = ["network.target"];
              X-Restart-Triggers = [configFile];
            };

            Service = {
              ExecStart = "${lib.getExe cfg.package}";
              Restart = "on-failure";
            };

            Install.WantedBy = ["default.target"];
          };
        };
      }
    );
  };
}
