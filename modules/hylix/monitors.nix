_: {
  flake.modules.generic.hylix = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      concatStringsSep
      mkIf
      mkOption
      mkOrder
      # keep-sorted end
      ;
    inherit
      (lib.self)
      # keep-sorted start
      mkHylixMonitorLine
      ordering
      toLua
      # keep-sorted end
      ;
    inherit
      (lib.types)
      # keep-sorted start
      anything
      listOf
      nullOr
      str
      submodule
      # keep-sorted end
      ;

    cfg = config.programs.hylix;

    lines = concatStringsSep "\n" (map (mkHylixMonitorLine toLua) cfg.monitors);

    monitorType = submodule {
      options = {
        # keep-sorted start block=yes newline_separated=yes
        extra = mkOption {
          description = "additional fields passed to hl.monitor()";

          type = anything;
          default = {};
        };

        mode = mkOption {
          description = "resolution and refresh rate (e.g. 1920x1080@60)";

          type = nullOr str;
          default = null;
        };

        output = mkOption {
          description = "monitor output name (e.g. DP-1, HDMI-A-1)";

          type = str;
        };

        position = mkOption {
          description = "position on the canvas (e.g. 0x0)";

          type = nullOr str;
          default = null;
        };

        scale = mkOption {
          description = "scale factor (string, e.g. \"1\" or \"1.5\")";

          type = nullOr str;
          default = null;
        };
        # keep-sorted end
      };
    };
  in {
    options.programs.hylix.monitors = mkOption {
      description = "monitor configurations";

      type = listOf monitorType;
      default = [];
    };

    config = mkIf (cfg.monitors != []) {
      programs.hylix._generatedConfig = mkOrder ordering.monitors lines;
    };
  };
}
