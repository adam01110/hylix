{lib}: let
  inherit
    (builtins)
    # keep-sorted start
    filter
    head
    # keep-sorted end
    ;
  inherit
    (lib)
    # keep-sorted start
    concatMap
    concatStringsSep
    foldl'
    optional
    optionalAttrs
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
  mkHylixBind = description: keys: dispatcher:
    {
      inherit
        # keep-sorted start
        description
        keys
        # keep-sorted end
        ;
    }
    // dispatcher;

  mkHylixBindGroup = category: binds: {
    inherit
      # keep-sorted start
      binds
      category
      # keep-sorted end
      ;
  };

  mkHylixDispatcher = toLua: bind: let
    candidates = [
      {
        condition = bind.exec != null;
        value = mkHylixLuaValueCall toLua "hl.dsp.exec_cmd" ([bind.exec] ++ optional (bind.execRules != null) bind.execRules);
      }
      {
        condition = bind.execRaw != null;
        value = mkHylixLuaValueCall toLua "hl.dsp.exec_raw" [bind.execRaw];
      }
      {
        condition = bind.lua != null;
        value = bind.lua;
      }
      {
        condition = bind.action != null;
        value = mkHylixLuaValueCall toLua "hl.dsp.${bind.action}" (optional (bind.args != null) bind.args);
      }
    ];
    matches = filter (candidate: candidate.condition) candidates;
  in
    if matches != []
    then (head matches).value
    else throw "bind must have one of: exec, action, lua";

  mkHylixBindLine = toLua: bind: let
    keysStr = concatStringsSep " + " bind.keys;
    dispatcher = mkHylixDispatcher toLua bind;
    bindOptions = cleanAttrs (bind.options // {inherit (bind) description;});
  in
    mkHylixLuaCall "hl.bind" ([(toLua keysStr) dispatcher] ++ optional (bindOptions != {}) (toLua bindOptions));

  mkHylixBindLines = toLua: binds: let
    buildBind = state: bind: let
      categoryChanged = bind.category != null && bind.category != state.category;
      nextIndex =
        if categoryChanged
        then state.index + 1
        else state.index;
      categoryLine =
        optional categoryChanged "-- ${toString nextIndex}. ${bind.category}";
    in {
      category =
        if categoryChanged
        then bind.category
        else state.category;
      index = nextIndex;
      lines = state.lines ++ categoryLine ++ [(mkHylixBindLine toLua bind)];
    };
  in
    (foldl' buildBind {
        category = null;
        index = 0;
        lines = [];
      }
      binds)
    .lines;

  mkHylixGroupedBinds = bindGroups:
    concatMap (group:
      map (bind:
        bind
        // optionalAttrs (bind.category == null) {
          inherit (group) category;
        })
      group.binds)
    bindGroups;
}
