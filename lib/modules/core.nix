{lib}: let
  inherit
    (lib)
    # keep-sorted start
    concatStringsSep
    filterAttrs
    mkIf
    mkOrder
    optionalString
    # keep-sorted end
    ;
in rec {
  cleanAttrs = filterAttrs (_: value: value != null);

  mkHylixLuaSection = name: text:
    optionalString (text != "") ''
      -- ${name}
      ${text}
    '';

  mkHylixGeneratedConfig = condition: order: name: text:
    mkIf condition {
      programs.hylix._generatedConfig = mkOrder order (mkHylixLuaSection name text);
    };

  mkHylixLines = lineFn: values:
    concatStringsSep "\n" (map lineFn values);

  mkHylixLuaCall = name: args: "${name}(${concatStringsSep ", " args})";

  mkHylixLuaValueCall = toLua: name: args: mkHylixLuaCall name (map toLua args);

  mkHylixLuaCallLines = toLua: func: values:
    mkHylixLines (value: mkHylixLuaValueCall toLua func [value]) values;
}
