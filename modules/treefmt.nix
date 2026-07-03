{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  perSystem = _: {
    treefmt = {
      programs = {
        # keep-sorted start
        alejandra.enable = true;
        deadnix.enable = true;
        keep-sorted.enable = true;
        nixf-diagnose.enable = true;
        statix.enable = true;
        # keep-sorted end
      };

      projectRootFile = "flake.nix";

      settings.global.excludes = [
        # keep-sorted start
        ".direnv/*"
        ".envrc"
        "assets/hylix-infra-sample.lua"
        "flake.nix"
        # keep-sorted end
      ];
    };
  };
}
