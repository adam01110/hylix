{lib}: let
  inherit
    (builtins)
    # keep-sorted start
    filter
    fromJSON
    head
    isString
    # keep-sorted end
    ;
  inherit
    (lib)
    # keep-sorted start
    concatStringsSep
    mapAttrsToList
    optional
    # keep-sorted end
    ;
  inherit
    (import ./core.nix {inherit lib;})
    # keep-sorted start
    cleanAttrs
    mkHylixLuaCall
    mkHylixLuaValueCall
    # keep-sorted end
    ;
in rec {
  mkHylixMonitorLine = toLua: monitor: let
    scaleVal =
      if monitor.scale != null && isString monitor.scale
      then fromJSON monitor.scale
      else monitor.scale;
    base = cleanAttrs {
      inherit (monitor) mode output position;
      scale = scaleVal;
    };
  in
    mkHylixLuaValueCall toLua "hl.monitor" [(base // monitor.extra)];

  mkHylixRuleLine = toLua: func: rule: mkHylixLuaValueCall toLua func [rule];

  mkHylixAutostartLine = toLua: entry:
    mkHylixLuaValueCall toLua "hl.exec_cmd" ([entry.cmd] ++ optional (entry.rules != null) entry.rules);

  mkHylixEnvLine = toLua: name: value:
    mkHylixLuaValueCall toLua "hl.env" [name value];

  mkHylixEnvLines = toLua: env:
    concatStringsSep "\n" (mapAttrsToList (mkHylixEnvLine toLua) env);

  mkHylixEventLine = toLua: entry: let
    callbacks = [
      {
        condition = entry.lua != null;
        value = entry.lua;
      }
      {
        condition = entry.exec != null;
        value = "function() ${mkHylixLuaValueCall toLua "hl.dsp.exec_cmd" [entry.exec]} end";
      }
    ];
    matches = filter (candidate: candidate.condition) callbacks;
  in
    if matches != []
    then mkHylixLuaCall "hl.on" [(toLua entry.event) (head matches).value]
    else "";
}
