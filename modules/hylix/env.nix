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
      mapAttrsToList
      mkIf
      mkOption
      mkOrder
      # keep-sorted end
      ;
    inherit (import ../../lib {inherit lib;}) ordering;
    inherit
      (lib.types)
      # keep-sorted start
      attrsOf
      str
      # keep-sorted end
      ;
    cfg = config.programs.hylix;

    envLines =
      concatStringsSep "\n"
      (mapAttrsToList (k: v: "hl.env(\"${k}\", \"${v}\")") cfg.env);
  in {
    options.programs.hylix.env = mkOption {
      description = "environment variables set via hl.env()";

      type = attrsOf str;
      default = {};
    };

    config = mkIf (cfg.env != {}) {
      programs.hylix._generatedConfig = mkOrder ordering.env envLines;
    };
  };
}
