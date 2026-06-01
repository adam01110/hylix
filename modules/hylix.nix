{inputs, ...}: {
  imports = [inputs.flake-parts.flakeModules.modules];

  flake.lib = import ../lib {lib = inputs.nixpkgs.lib;};
}
