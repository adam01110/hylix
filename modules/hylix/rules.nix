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
      mkMerge
      mkOption
      # keep-sorted end
      ;
    inherit
      (import ../../lib {inherit lib;})
      # keep-sorted start
      mkHylixGeneratedConfig
      mkHylixLines
      mkHylixRuleLine
      ordering
      toLua
      # keep-sorted end
      ;
    inherit
      (lib.types)
      # keep-sorted start
      anything
      listOf
      # keep-sorted end
      ;
    cfg = config.programs.hylix;

    buildRule = mkHylixRuleLine toLua;
    ruleSections = [
      {
        func = "hl.window_rule";
        order = ordering.windowRules;
        section = "rules.window";
        values = cfg.rules.window;
      }
      {
        func = "hl.workspace_rule";
        order = ordering.workspaceRules;
        section = "rules.workspace";
        values = cfg.rules.workspace;
      }
      {
        func = "hl.layer_rule";
        order = ordering.layerRules;
        section = "rules.layer";
        values = cfg.rules.layer;
      }
    ];
    mkRuleSection = {
      func,
      order,
      section,
      values,
    }:
      mkHylixGeneratedConfig (values != []) order section (mkHylixLines (buildRule func) values);
  in {
    options.programs.hylix.rules = {
      # keep-sorted start block=yes newline_separated=yes
      layer = mkOption {
        description = "layer rules passed to hl.layer_rule()";

        type = listOf anything;
        default = [];
      };

      window = mkOption {
        description = "window rules passed to hl.window_rule()";

        type = listOf anything;
        default = [];
      };

      workspace = mkOption {
        description = "workspace rules passed to hl.workspace_rule()";

        type = listOf anything;
        default = [];
      };
      # keep-sorted end
    };

    config = mkMerge (map mkRuleSection ruleSections);
  };
}
