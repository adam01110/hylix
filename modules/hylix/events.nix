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
      (import ../../lib {inherit lib;})
      # keep-sorted start
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

    lines =
      concatStringsSep "\n"
      (map (
          entry:
            if entry.lua != null
            then "hl.on(${toLua entry.event}, ${entry.lua})"
            else if entry.exec != null
            then "hl.on(${toLua entry.event}, function() hl.dsp.exec_cmd(${toLua entry.exec}) end)"
            else ""
        )
        cfg.events);
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

    config = mkIf (cfg.events != []) {
      programs.hylix._generatedConfig = mkOrder ordering.events lines;
    };
  };
}
