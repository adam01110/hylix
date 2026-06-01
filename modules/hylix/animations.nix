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
      mkIf
      mkMerge
      mkOption
      mkOrder
      # keep-sorted end
      ;
    inherit
      (import ../../lib {inherit lib;})
      # keep-sorted start
      mkHylixAnimationLines
      mkHylixCurveLines
      ordering
      toLua
      # keep-sorted end
      ;
    inherit
      (lib.types)
      # keep-sorted start
      attrsOf
      bool
      either
      enum
      float
      int
      listOf
      nullOr
      str
      submodule
      # keep-sorted end
      ;

    cfg = config.programs.hylix;

    curveLines = mkHylixCurveLines toLua cfg.animations.curves;
    animLines = mkHylixAnimationLines toLua cfg.animations.animations;

    curveType = submodule {
      options = {
        # keep-sorted start block=yes newline_separated=yes
        # spring options
        dampening = mkOption {
          description = "spring dampening";

          type = nullOr (either int float);
          default = null;
        };

        mass = mkOption {
          description = "spring mass";

          type = nullOr (either int float);
          default = null;
        };

        # bezier options
        points = mkOption {
          description = "bezier control points [x1, y1, x2, y2]";

          type = nullOr (listOf float);
          default = null;
        };

        stiffness = mkOption {
          description = "spring stiffness";

          type = nullOr (either int float);
          default = null;
        };

        type = mkOption {
          description = "curve type";

          type = enum ["bezier" "spring"];
        };
        # keep-sorted end
      };
    };

    animationType = submodule {
      options = {
        # keep-sorted start block=yes newline_separated=yes
        bezier = mkOption {
          description = "name of a bezier curve to use";

          type = nullOr str;
          default = null;
        };

        enabled = mkOption {
          description = "whether this animation is enabled";

          type = bool;
          default = true;
        };

        leaf = mkOption {
          description = "animation leaf name";

          type = str;
        };

        speed = mkOption {
          description = "animation speed";

          type = nullOr (either int float);
          default = null;
        };

        spring = mkOption {
          description = "name of a spring curve to use";

          type = nullOr str;
          default = null;
        };

        style = mkOption {
          description = "animation style";

          type = nullOr str;
          default = null;
        };
        # keep-sorted end
      };
    };
  in {
    options.programs.hylix.animations = {
      # keep-sorted start block=yes newline_separated=yes
      animations = mkOption {
        description = "animation configurations";

        type = listOf animationType;
        default = [];
      };

      curves = mkOption {
        description = "named animation curves";

        type = attrsOf curveType;
        default = {};
      };
      # keep-sorted end
    };

    config = mkMerge [
      (mkIf (cfg.animations.curves != {}) {
        programs.hylix._generatedConfig = mkOrder ordering.curves curveLines;
      })

      (mkIf (cfg.animations.animations != []) {
        programs.hylix._generatedConfig = mkOrder ordering.animations animLines;
      })
    ];
  };
}
