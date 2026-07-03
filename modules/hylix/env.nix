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
      mkHylixEnvLines
      mkHylixGeneratedConfig
      ordering
      toLua
      # keep-sorted end
      ;
    inherit
      (lib.types)
      # keep-sorted start
      attrsOf
      str
      # keep-sorted end
      ;
    cfg = config.programs.hylix;

    envLines = mkHylixEnvLines toLua cfg.env;
  in {
    options.programs.hylix.env = mkOption {
      description = "environment variables set via hl.env()";

      type = attrsOf str;
      default = {};
    };

    config = mkHylixGeneratedConfig (cfg.env != {}) ordering.env envLines;
  };
}
