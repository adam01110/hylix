{lib}: let
  inherit
    (lib)
    # keep-sorted start
    concatStringsSep
    filterAttrs
    mkIf
    mkOrder
    # keep-sorted end
    ;
in rec {
  cleanAttrs = filterAttrs (_: value: value != null);

  mkHylixGeneratedConfig = condition: order: text:
    mkIf condition {
      programs.hylix._generatedConfig = mkOrder order text;
    };

  mkHylixLines = lineFn: values:
    concatStringsSep "\n" (map lineFn values);

  mkHylixLuaCall = name: args: "${name}(${concatStringsSep ", " args})";

  mkHylixLuaValueCall = toLua: name: args: mkHylixLuaCall name (map toLua args);

  mkHylixLuaCallLines = toLua: func: values:
    mkHylixLines (value: mkHylixLuaValueCall toLua func [value]) values;
}
