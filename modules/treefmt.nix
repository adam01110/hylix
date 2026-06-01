{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  perSystem = _: {
    treefmt = {
      programs = {
        # keep-sorted start
        alejandra.enable = true;
        deadnix.enable = true;
        nixf-diagnose.enable = true;
        statix.enable = true;
        # keep-sorted end

        keep-sorted.enable = true;
      };

      projectRootFile = "flake.nix";

      settings.global.excludes = [
        # keep-sorted start
        ".direnv/*"
        "flake.nix"
        # keep-sorted end
      ];
    };
  };
}
