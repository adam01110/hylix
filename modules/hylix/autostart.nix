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
    inherit (lib.self) ordering;
    inherit
      (lib.types)
      # keep-sorted start
      listOf
      str
      # keep-sorted end
      ;

    cfg = config.programs.hylix;

    lines =
      concatStringsSep "\n"
      (map (cmd: "hl.exec_cmd(\"${cmd}\")") cfg.autostart);
  in {
    options.programs.hylix.autostart = mkOption {
      description = "commands to run at startup via hl.exec_cmd()";

      type = listOf str;
      default = [];
    };

    config = mkIf (cfg.autostart != []) {
      programs.hylix._generatedConfig = mkOrder ordering.autostart lines;
    };
  };
}
