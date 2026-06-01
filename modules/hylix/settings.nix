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
      mkIf
      mkOption
      mkOrder
      # keep-sorted end
      ;
    inherit
      (lib.self)
      # keep-sorted start
      ordering
      toLua
      #keep-sorted end
      ;
    inherit (lib.types) anything;
    cfg = config.programs.hylix;
  in {
    options.programs.hylix.settings = mkOption {
      description = "freeform settings passed to hl.config()";

      type = anything;
      default = {};
    };

    config = mkIf (cfg.settings != {}) {
      programs.hylix._generatedConfig =
        mkOrder ordering.settings
        "hl.config(${toLua cfg.settings})";
    };
  };
}
