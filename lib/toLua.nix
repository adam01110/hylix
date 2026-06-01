{lib}: let
  inherit
    (builtins)
    # keep-sorted start
    attrNames
    elem
    filter
    genList
    hasAttr
    head
    isAttrs
    isBool
    isFloat
    isInt
    isList
    isPath
    isString
    length
    tail
    typeOf
    # keep-sorted end
    ;
  inherit
    (lib)
    # keep-sorted start
    all
    boolToString
    concatStringsSep
    init
    last
    replaceStrings
    stringToCharacters
    # keep-sorted end
    ;

  # Strip trailing zeros from float strings (3.140000 -> 3.14) while keeping
  # at least one decimal digit (1.000000 -> 1.0).
  stripTrailingZeros = s: let
    chars = stringToCharacters s;
    go = cs:
      if cs == []
      then ["0"]
      else if last cs == "0"
      then go (init cs)
      else if last cs == "."
      then cs ++ ["0"]
      else cs;
  in
    if elem "." chars
    then concatStringsSep "" (go chars)
    else s;

  # Check if a string is a valid Lua identifier.
  isIdentifier = s: let
    reserved = [
      # keep-sorted start
      "and"
      "break"
      "do"
      "else"
      "elseif"
      "end"
      "false"
      "for"
      "function"
      "goto"
      "if"
      "in"
      "local"
      "nil"
      "not"
      "or"
      "repeat"
      "return"
      "then"
      "true"
      "until"
      "while"
      # keep-sorted end
    ];
    chars = stringToCharacters s;
    isAlpha = c: (c >= "a" && c <= "z") || (c >= "A" && c <= "Z") || c == "_";
    isAlnum = c: isAlpha c || (c >= "0" && c <= "9");
    firstOk = chars != [] && isAlpha (head chars);
    restOk = all isAlnum (tail chars);
  in
    s
    != ""
    && firstOk
    && (length chars == 1 || restOk)
    && !(elem s reserved);

  escapeLuaString = s:
    replaceStrings
    ["\\" "\"" "\n" "\r" "\t"]
    ["\\\\" "\\\"" "\\n" "\\r" "\\t"]
    s;

  indent = depth:
    concatStringsSep "" (genList (_: "  ") depth);

  toLuaValue = depth: value:
    if value == null
    then "nil"
    else if isBool value
    then boolToString value
    else if isInt value
    then toString value
    else if isFloat value
    then stripTrailingZeros (toString value)
    else if isString value
    then "\"${escapeLuaString value}\""
    else if isPath value
    then "\"${escapeLuaString (toString value)}\""
    else if isList value
    then toLuaList depth value
    else if isAttrs value
    then
      if hasAttr "__raw" value
      then value.__raw
      else toLuaTable depth value
    else throw "toLua: unsupported type ${typeOf value}";

  toLuaList = depth: xs: let
    inner = indent (depth + 1);
    items = map (x: "${inner}${toLuaValue (depth + 1) x},") xs;
  in
    if xs == []
    then "{}"
    else "{\n${concatStringsSep "\n" items}\n${indent depth}}";

  toLuaTable = depth: attrs: let
    keys = filter (k: attrs.${k} != null) (attrNames attrs);
    inner = indent (depth + 1);

    formatKey = k:
      if isIdentifier k
      then k
      else "[\"${escapeLuaString k}\"]";
    formatEntry = k: "${inner}${formatKey k} = ${toLuaValue (depth + 1) attrs.${k}},";

    entries = map formatEntry keys;
  in
    if keys == []
    then "{}"
    else "{\n${concatStringsSep "\n" entries}\n${indent depth}}";
in {
  # Serialize a Nix value to a Lua expression string.
  toLua = toLuaValue 0;

  # Serialize a Nix value to a Lua expression string at a given indentation depth.
  toLuaAt = toLuaValue;
}
