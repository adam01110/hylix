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
      (lib.self)
      # keep-sorted start
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

    lines =
      concatStringsSep "\n"
      (map (d: "hl.device(${toLua d})") cfg.devices);
  in {
    options.programs.hylix.devices = mkOption {
      description = "device configurations passed to hl.device()";

      type = listOf anything;
      default = [];
    };

    config = mkIf (cfg.devices != []) {
      programs.hylix._generatedConfig = mkOrder ordering.devices lines;
    };
  };
}
