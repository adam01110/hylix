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
      mkMerge
      mkOption
      # keep-sorted end
      ;
    inherit
      (import ../../lib {inherit lib;})
      # keep-sorted start
      mkHylixGeneratedConfig
      ordering
      # keep-sorted end
      ;
    inherit
      (lib.types)
      # keep-sorted start
      lines
      listOf
      # keep-sorted end
      ;

    cfg = config.programs.hylix;
  in {
    options.programs.hylix.extraLua = mkOption {
      description = "raw lua appended to the config";

      type = lines;
      default = "";
    };

    options.programs.hylix.extraLuaSnippets = mkOption {
      description = "Lua snippets concatenated into hylix's extraLua.";

      type = listOf lines;
      default = [];
    };

    config = mkMerge [
      {
        programs.hylix = {
          extraLua = mkIf (cfg.extraLuaSnippets != []) (concatStringsSep "\n" cfg.extraLuaSnippets);
        };
      }

      (mkHylixGeneratedConfig (cfg.extraLua != "") ordering.extraLua "extraLua" cfg.extraLua)
    ];
  };
}
