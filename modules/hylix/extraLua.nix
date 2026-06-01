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
    inherit (import ../../lib {inherit lib;}) ordering;
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

    config = {
      programs.hylix = {
        extraLua = mkIf (cfg.extraLuaSnippets != []) (concatStringsSep "\n" cfg.extraLuaSnippets);
        _generatedConfig = mkIf (cfg.extraLua != "") (mkOrder ordering.extraLua cfg.extraLua);
      };
    };
  };
}
