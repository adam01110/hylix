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
      anything
      listOf
      # keep-sorted end
      ;

    cfg = config.programs.hylix;

    lines = mkHylixLuaCallLines toLua "hl.gesture" cfg.gestures;
  in {
    options.programs.hylix.gestures = mkOption {
      description = "gesture configurations passed to hl.gesture()";

      type = listOf anything;
      default = [];
    };

    config = mkHylixGeneratedConfig (cfg.gestures != []) ordering.gestures "gestures" lines;
  };
}
