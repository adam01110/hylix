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
      mkHylixLuaValueCall
      ordering
      toLua
      # keep-sorted end
      ;
    inherit (lib.types) anything;
    cfg = config.programs.hylix;
  in {
    options.programs.hylix.settings = mkOption {
      description = "freeform settings passed to hl.config()";

      type = anything;
      default = {};
    };

    config =
      mkHylixGeneratedConfig
      (cfg.settings != {})
      ordering.settings
      (mkHylixLuaValueCall toLua "hl.config" [cfg.settings]);
  };
}
