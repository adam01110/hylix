{lib}: let
  inherit
    (builtins)
    # keep-sorted start
    isString
    fromJSON
    # keep-sorted end
    ;
  inherit
    (lib)
    # keep-sorted start
    concatMap
    concatStringsSep
    filterAttrs
    foldl'
    mapAttrsToList
    optionalAttrs
    # keep-sorted end
    ;

  cleanAttrs = filterAttrs (_: value: value != null);
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

  mkHylixDispatcher = toLua: bind:
    if bind.exec != null
    then
      if bind.execRules != null
      then "hl.dsp.exec_cmd(${toLua bind.exec}, ${toLua bind.execRules})"
      else "hl.dsp.exec_cmd(${toLua bind.exec})"
    else if bind.execRaw != null
    then "hl.dsp.exec_raw(${toLua bind.execRaw})"
    else if bind.lua != null
    then bind.lua
    else if bind.action != null
    then let
      argsStr =
        if bind.args != null
        then "(${toLua bind.args})"
        else "()";
    in "hl.dsp.${bind.action}${argsStr}"
    else throw "bind must have one of: exec, action, lua";

  mkHylixBindLine = toLua: bind: let
    keysStr = concatStringsSep " + " bind.keys;
    dispatcher = mkHylixDispatcher toLua bind;
    bindOptions = cleanAttrs (bind.options // {inherit (bind) description;});
  in
    if bindOptions != {}
    then "hl.bind(${toLua keysStr}, ${dispatcher}, ${toLua bindOptions})"
    else "hl.bind(${toLua keysStr}, ${dispatcher})";

  mkHylixBindLines = toLua: binds: let
    buildBind = state: bind: let
      categoryChanged = bind.category != null && bind.category != state.category;
      nextIndex =
        if categoryChanged
        then state.index + 1
        else state.index;
      categoryLine =
        if categoryChanged
        then ["-- ${toString nextIndex}. ${bind.category}"]
        else [];
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
        // {
          category =
            if bind.category != null
            then bind.category
            else group.category;
        })
      group.binds)
    bindGroups;

  mkHylixMonitorLine = toLua: monitor: let
    scaleVal =
      if monitor.scale != null && isString monitor.scale
      then fromJSON monitor.scale
      else monitor.scale;
    base =
      {inherit (monitor) output;}
      // optionalAttrs (monitor.mode != null) {inherit (monitor) mode;}
      // optionalAttrs (monitor.position != null) {inherit (monitor) position;}
      // optionalAttrs (scaleVal != null) {scale = scaleVal;};
  in "hl.monitor(${toLua (base // monitor.extra)})";

  mkHylixRuleLine = toLua: func: rule: "${func}(${toLua rule})";

  mkHylixCurveLine = toLua: name: curve: let
    table =
      if curve.type == "bezier"
      then {
        type = "bezier";
        points = [
          [
            (builtins.elemAt curve.points 0)
            (builtins.elemAt curve.points 1)
          ]
          [
            (builtins.elemAt curve.points 2)
            (builtins.elemAt curve.points 3)
          ]
        ];
      }
      else
        cleanAttrs {
          inherit
            (curve)
            dampening
            mass
            stiffness
            type
            ;
        };
  in "hl.curve(\"${name}\", ${toLua table})";

  mkHylixAnimationLine = toLua: anim: let
    table =
      {inherit (anim) leaf enabled;}
      // optionalAttrs (anim.speed != null) {inherit (anim) speed;}
      // optionalAttrs (anim.bezier != null) {inherit (anim) bezier;}
      // optionalAttrs (anim.spring != null) {inherit (anim) spring;}
      // optionalAttrs (anim.style != null) {inherit (anim) style;};
  in "hl.animation(${toLua table})";

  mkHylixCurveLines = toLua: curves:
    concatStringsSep "\n" (mapAttrsToList (mkHylixCurveLine toLua) curves);

  mkHylixAnimationLines = toLua: animations:
    concatStringsSep "\n" (map (mkHylixAnimationLine toLua) animations);
}
