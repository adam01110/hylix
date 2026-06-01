{
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
      mkHylixBindLines
      mkHylixGroupedBinds
      ordering
      toLua
      # keep-sorted end
      ;
    inherit
      (lib.types)
      # keep-sorted start
      anything
      attrsOf
      listOf
      nullOr
      str
      submodule
      # keep-sorted end
      ;

    cfg = config.programs.hylix;

    groupedBinds = mkHylixGroupedBinds cfg.bindGroups;
    allBinds = cfg.binds ++ groupedBinds;
    lines = mkHylixBindLines toLua allBinds;

    bindType = submodule {
      options = {
        # keep-sorted start block=yes newline_separated=yes
        action = mkOption {
          description = "hyprland dispatcher action (e.g. \"window.close\", \"focus\")";

          type = nullOr str;
          default = null;
        };

        args = mkOption {
          description = "arguments for the action dispatcher";

          type = anything;
          default = null;
        };

        category = mkOption {
          description = "optional keybind category";

          type = nullOr str;
          default = null;
        };

        description = mkOption {
          description = "optional bind description";

          type = nullOr str;
          default = null;
        };

        exec = mkOption {
          description = "command to execute (shorthand for hl.dsp.exec_cmd)";

          type = nullOr str;
          default = null;
        };

        execRaw = mkOption {
          description = "command to execute via hl.dsp.exec_raw";

          type = nullOr str;
          default = null;
        };

        execRules = mkOption {
          description = "hyprland dispatcher rules for the exec command (e.g. {float = true; move = {0, 0;}})";

          type = nullOr anything;
          default = null;
        };

        keys = mkOption {
          description = "key combination (e.g. [\"SUPER\" \"q\"])";

          type = listOf str;
        };

        lua = mkOption {
          description = "raw lua function body";

          type = nullOr str;
          default = null;
        };

        options = mkOption {
          description = "bind options (repeating, locked, etc)";

          type = attrsOf anything;
          default = {};
        };
        # keep-sorted end
      };
    };

    bindGroupType = submodule {
      options = {
        # keep-sorted start block=yes newline_separated=yes
        binds = mkOption {
          description = "keybindings in this group";

          type = listOf bindType;
          default = [];
        };

        category = mkOption {
          description = "keybind category";

          type = str;
        };
        # keep-sorted end
      };
    };
  in {
    options.programs.hylix.binds = mkOption {
      description = "keybindings";

      type = listOf bindType;
      default = [];
    };

    options.programs.hylix.bindGroups = mkOption {
      description = "grouped keybindings";

      type = listOf bindGroupType;
      default = [];
    };

    config = mkIf (allBinds != []) {
      programs.hylix._generatedConfig = mkOrder ordering.binds (concatStringsSep "\n" lines);
    };
  };
}
