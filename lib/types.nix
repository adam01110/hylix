{lib}: let
  inherit
    (lib)
    # keep-sorted start
    last
    mkOptionType
    # keep-sorted end
    ;

  # Recursive type that accepts any value valid for Lua serialization:
  # null, bool, int, float, string, path, list of luaValue,
  # attrset of luaValue, or { __raw = "..."; }
  luaValue = mkOptionType {
    description = "nix value serializable to lua (null, bool, int, float, string, list, attrset, or { __raw = ... })";

    name = "luaValue";
    check = _: true;
    merge = _: defs: (last defs).value;
  };
in {
  inherit luaValue;
}
