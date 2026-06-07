{lib}: let
  inherit
    (builtins)
    # keep-sorted start
    filter
    fromJSON
    hasAttr
    isString
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
    replaceStrings
    # keep-sorted end
    ;

  cleanAttrs = filterAttrs (_: value: value != null);

  sanitizeCurveName = replaceStrings [":" "/" " " "-" "."] ["_" "_" "_" "_" "_"];

  mkDerivedSpringName = anim: "hylix_${sanitizeCurveName anim.leaf}_${sanitizeCurveName anim.spring}";

  scaleSpringForSpeed = speed: curve: let
    timeScale = speed / 10.0;
  in
    curve
    // optionalAttrs ((curve.stiffness or null) != null) {
      stiffness = curve.stiffness / (timeScale * timeScale);
    }
    // optionalAttrs ((curve.dampening or null) != null) {
      dampening = curve.dampening / timeScale;
    };
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

  mkHylixAnimationLineWithCurves = toLua: curves: anim: let
    bezier = anim.bezier or null;
    speed = anim.speed or null;
    canScaleSpring = (anim.spring or null) != null && speed != null && speed > 0 && hasAttr anim.spring curves;
    spring =
      if canScaleSpring
      then mkDerivedSpringName anim
      else anim.spring or null;
    style = anim.style or null;
    table =
      {inherit (anim) leaf enabled;}
      // optionalAttrs (speed != null) {inherit speed;}
      // optionalAttrs (bezier != null) {inherit bezier;}
      // optionalAttrs (spring != null) {inherit spring;}
      // optionalAttrs (style != null) {inherit style;};
  in "hl.animation(${toLua table})";

  mkHylixAnimationLine = toLua: anim:
    mkHylixAnimationLineWithCurves toLua {} anim;

  mkHylixDerivedSpringLine = toLua: curves: anim:
    if
      (anim.spring or null)
      != null
      && (anim.speed or null) != null
      && anim.speed > 0
      && hasAttr anim.spring curves
    then let
      curve = curves.${anim.spring};
    in
      if curve.type == "spring"
      then mkHylixCurveLine toLua (mkDerivedSpringName anim) (scaleSpringForSpeed anim.speed curve)
      else null
    else null;

  mkHylixCurveLines = toLua: curves:
    concatStringsSep "\n" (mapAttrsToList (mkHylixCurveLine toLua) curves);

  mkHylixAnimationLinesWithCurves = toLua: curves: animations:
    concatStringsSep "\n" (filter (line: line != null) (
      (map (mkHylixDerivedSpringLine toLua curves) animations)
      ++ (map (mkHylixAnimationLineWithCurves toLua curves) animations)
    ));

  mkHylixAnimationLines = toLua: animations:
    mkHylixAnimationLinesWithCurves toLua {} animations;
}
