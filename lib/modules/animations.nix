{lib}: let
  inherit
    (builtins)
    # keep-sorted start
    filter
    hasAttr
    # keep-sorted end
    ;
  inherit
    (lib)
    # keep-sorted start
    concatStringsSep
    mapAttrsToList
    optionalAttrs
    pipe
    replaceStrings
    # keep-sorted end
    ;
  inherit
    (import ./core.nix {inherit lib;})
    # keep-sorted start
    cleanAttrs
    mkHylixLuaValueCall
    # keep-sorted end
    ;

  sanitizeCurveName = replaceStrings [":" "/" " " "-" "."] ["_" "_" "_" "_" "_"];

  mkDerivedSpringName = anim: "hylix_${sanitizeCurveName anim.leaf}_${sanitizeCurveName anim.spring}";

  canScaleSpring = curves: anim:
    (anim.spring or null)
    != null
    && (anim.speed or null) != null
    && anim.speed > 0
    && hasAttr anim.spring curves;

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
  in
    mkHylixLuaValueCall toLua "hl.curve" [name table];

  mkHylixAnimationLineWithCurves = toLua: curves: anim: let
    bezier = anim.bezier or null;
    speed = anim.speed or null;
    spring =
      if canScaleSpring curves anim
      then mkDerivedSpringName anim
      else anim.spring or null;
    style = anim.style or null;
    table = cleanAttrs {
      inherit (anim) enabled leaf;
      inherit bezier speed spring style;
    };
  in
    mkHylixLuaValueCall toLua "hl.animation" [table];

  mkHylixAnimationLine = toLua: anim:
    mkHylixAnimationLineWithCurves toLua {} anim;

  mkHylixDerivedSpringLine = toLua: curves: anim:
    if canScaleSpring curves anim
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
    pipe animations [
      (items:
        (map (mkHylixDerivedSpringLine toLua curves) items)
        ++ (map (mkHylixAnimationLineWithCurves toLua curves) items))
      (filter (line: line != null))
      (concatStringsSep "\n")
    ];

  mkHylixAnimationLines = toLua: animations:
    mkHylixAnimationLinesWithCurves toLua {} animations;
}
