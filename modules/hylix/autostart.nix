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
      mkHylixAutostartLine
      mkHylixGeneratedConfig
      mkHylixLines
      ordering
      toLua
      # keep-sorted end
      ;
    inherit
      (lib.types)
      # keep-sorted start
      anything
      listOf
      nullOr
      str
      submodule
      # keep-sorted end
      ;

    cfg = config.programs.hylix;

    lines = mkHylixLines (mkHylixAutostartLine toLua) cfg.autostart;
  in {
    options.programs.hylix.autostart = mkOption {
      description = "commands to run at startup via hl.exec_cmd()";

      type = listOf (submodule {
        options = {
          # keep-sorted start block=yes newline_separated=yes
          cmd = mkOption {
            description = "the command to run";

            type = str;
          };

          rules = mkOption {
            description = "optional Hyprland rules table";

            type = nullOr anything;
            default = null;
          };
          # keep-sorted end
        };
      });
      default = [];
    };

    config = mkHylixGeneratedConfig (cfg.autostart != []) ordering.autostart lines;
  };
}
