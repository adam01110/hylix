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
      mkOption
      # keep-sorted end
      ;
    inherit
      (import ../../lib {inherit lib;})
      # keep-sorted start
      mkHylixGeneratedConfig
      mkHylixLuaCallLines
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

    lines = mkHylixLuaCallLines toLua "hl.notification.create" cfg.notifications;
  in {
    options.programs.hylix.notifications = mkOption {
      description = "notifications sent on startup via hl.notification.create()";

      type = listOf (submodule {
        options = {
          # keep-sorted start block=yes newline_separated=yes
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
          # keep-sorted end
        };
      });
      default = [];
    };

    config = mkHylixGeneratedConfig (cfg.notifications != []) ordering.notifications "notifications" lines;
  };
}
