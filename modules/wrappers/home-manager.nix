{config, ...}: let
  hmModule = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      mkEnableOption
      mkIf
      # keep-sorted end
      ;

    cfg = config.programs.hylix;
    hyprlandEnabled = config.wayland.windowManager.hyprland;
  in {
    options.programs.hylix.enable = mkEnableOption "hylix hyprland lua config generator";

    config = mkIf cfg.enable {
      wayland.windowManager.hyprland.extraConfig = mkIf hyprlandEnabled cfg._generatedConfig;
      xdg.configFile."hypr/hyprland.lua".text = mkIf (!hyprlandEnabled) cfg._generatedConfig;
    };
  };
in {
  flake.homeManagerModules.default = {
    imports = [
      config.flake.modules.generic.hylix
      hmModule
    ];
  };
}
