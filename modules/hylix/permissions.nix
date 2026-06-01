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
    inherit (import ../../lib {inherit lib;}) toLua ordering;
    inherit
      (lib.types)
      # keep-sorted start
      listOf
      str
      submodule
      # keep-sorted end
      ;

    cfg = config.programs.hylix;

    permType = submodule {
      options = {
        # keep-sorted start block=yes newline_separated=yes
        binary = mkOption {
          description = "binary path or regex to match";

          type = str;
        };

        mode = mkOption {
          description = "permission mode (e.g. \"allow\", \"ask\", \"deny\")";

          type = str;
        };

        type = mkOption {
          description = "permission type (e.g. \"screenshot\", \"input\")";

          type = str;
        };
        # keep-sorted end
      };
    };

    lines =
      concatStringsSep "\n"
      (map (p: "hl.permission(${toLua {inherit (p) binary mode type;}})") cfg.permissions);
  in {
    options.programs.hylix.permissions = mkOption {
      description = "permission rules";

      type = listOf permType;
      default = [];
    };

    config = mkIf (cfg.permissions != []) {
      programs.hylix._generatedConfig = mkOrder ordering.permissions lines;
    };
  };
}
