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
      ordering
      toLua
      # keep-sorted end
      ;
    inherit
      (lib.types)
      # keep-sorted start
      int
      listOf
      nullOr
      str
      submodule
      # keep-sorted end
      ;

    cfg = config.programs.hylix;

    lines =
      concatStringsSep "\n"
      (map (n: "hl.notification.create(${toLua n})") cfg.notifications);
  in {
    options.programs.hylix.notifications = mkOption {
      description = "notifications sent on startup via hl.notification.create()";

      type = listOf (submodule {
        options = {
          group = mkOption {
            description = "notification group for grouping/dedup";

            type = nullOr str;
            default = null;
          };

          icon = mkOption {
            description = "icon (e.g. \"info\", \"warning\", \"error\")";

            type = nullOr str;
            default = null;
          };

          text = mkOption {
            description = "notification text";

            type = str;
          };

          time = mkOption {
            description = "display duration in milliseconds";

            type = int;
            default = 5000;
          };
        };
      });
      default = [];
    };

    config = mkIf (cfg.notifications != []) {
      programs.hylix._generatedConfig = mkOrder ordering.notifications lines;
    };
  };
}
