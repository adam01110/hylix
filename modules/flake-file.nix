{inputs, ...}: {
  imports = [inputs.flake-file.flakeModules.default];

  flake-file = {
    description = "Hyprland configuration framework built on Nix modules";
    outputs = ''
      inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)
    '';

    inputs = {
      # keep-sorted start block=yes newline_separated=yes
      flake-file.url = "github:denful/flake-file";

      flake-parts = {
        url = "github:hercules-ci/flake-parts";
        inputs.nixpkgs-lib.follows = "nixpkgs";
      };

      import-tree.url = "github:vic/import-tree";

      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      # keep-sorted end
    };
  };
}
