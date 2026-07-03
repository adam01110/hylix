{lib}: let
  animations = import ./modules/animations.nix {inherit lib;};
  binds = import ./modules/binds.nix {inherit lib;};
  core = import ./modules/core.nix {inherit lib;};
  hyprland = import ./modules/hyprland.nix {inherit lib;};
in
  removeAttrs core ["cleanAttrs"]
  // binds
  // hyprland
  // animations
