{inputs, ...}: let
  lib = inputs.nixpkgs.lib.extend (_final: prev: {
    self = import ../lib {lib = prev;};
  });
in {
  imports = [inputs.flake-parts.flakeModules.modules];

  flake.lib = lib;
}
