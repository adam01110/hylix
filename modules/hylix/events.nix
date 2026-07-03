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
      mkHylixEventLine
      mkHylixGeneratedConfig
      mkHylixLines
      ordering
      toLua
      # keep-sorted end
      ;
    inherit
      (lib.types)
      # keep-sorted start
      listOf
      nullOr
      str
      submodule
      # keep-sorted end
      ;

    cfg = config.programs.hylix;

    lines = mkHylixLines (mkHylixEventLine toLua) cfg.events;
  in {
    options.programs.hylix.events = mkOption {
      description = "Hyprland event hooks via hl.on()";

      type = listOf (submodule {
        options = {
          event = mkOption {
            description = "hyprland event name (e.g. \"hyprland.start\", \"window.active\", \"workspace.active\")";

            type = str;
          };

          exec = mkOption {
            description = "command to execute when the event fires";

            type = nullOr str;
            default = null;
          };

          lua = mkOption {
            description = "raw Lua function body for the event callback (e.g. ''function(w, ws) ... end'')";

            type = nullOr str;
            default = null;
          };
        };
      });
      default = [];
    };

    config = mkHylixGeneratedConfig (cfg.events != []) ordering.events lines;
  };
}
