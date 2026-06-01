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
    inherit (lib.self) toLua ordering;
    inherit
      (lib.types)
      # keep-sorted start
      anything
      listOf
      # keep-sorted end
      ;

    cfg = config.programs.hylix;

    lines =
      concatStringsSep "\n"
      (map (g: "hl.gesture(${toLua g})") cfg.gestures);
  in {
    options.programs.hylix.gestures = mkOption {
      description = "gesture configurations passed to hl.gesture()";

      type = listOf anything;
      default = [];
    };

    config = mkIf (cfg.gestures != []) {
      programs.hylix._generatedConfig = mkOrder ordering.gestures lines;
    };
  };
}
