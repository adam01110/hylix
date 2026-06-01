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
      mkMerge
      mkOption
      mkOrder
      # keep-sorted end
      ;
    inherit
      (import ../../lib {inherit lib;})
      # keep-sorted start
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

    config = mkMerge [
      (mkIf (cfg.rules.window != []) {
        programs.hylix._generatedConfig =
          mkOrder ordering.windowRules
          (concatStringsSep "\n" (map (buildRule "hl.window_rule") cfg.rules.window));
      })

      (mkIf (cfg.rules.workspace != []) {
        programs.hylix._generatedConfig =
          mkOrder ordering.workspaceRules
          (concatStringsSep "\n" (map (buildRule "hl.workspace_rule") cfg.rules.workspace));
      })

      (mkIf (cfg.rules.layer != []) {
        programs.hylix._generatedConfig =
          mkOrder ordering.layerRules
          (concatStringsSep "\n" (map (buildRule "hl.layer_rule") cfg.rules.layer));
      })
    ];
  };
}
