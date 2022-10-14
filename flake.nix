{
  description = "Umons LaTeX";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    with flake-utils.lib; eachSystem allSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfreePredicate = (pkg: true);
          };
        };

        umons-latex = pkgs.stdenv.mkDerivation {
            name = "umons-latex";
            pname = "umons-latex";
            src = self;

            dontBuild = true;

            installPhase = ''
                runHook preInstall

                mkdir -p $out/tex/latex
                cp -ar $src $out/tex/latex/umons-latex

                runHook postInstall
            '';

            tlType = "run";
        };
      in
      {
        # Nix shell / nix build
        packages.default = umons-latex;
      });
}
