_: {
  flake.modules.generic.hylix = {lib, ...}: let
    inherit (lib) mkOption;
    inherit (lib.types) lines;
  in {
    options.programs.hylix._generatedConfig = mkOption {
      description = "generated hyprland lua config (assembled from all modules)";

      type = lines;
      default = "";
      internal = true;
    };
  };
}
