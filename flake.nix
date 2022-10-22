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

                mkdir -p $out/tex/latex/umons
                cp -ar $src/src/* $out/tex/latex/umons

                runHook postInstall
            '';

            tlType = "run";
        };

        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-full latex-bin latexmk;
          umons-latex = {
            pkgs = [ umons-latex ];
          };
        };
      in
      {
        # Nix shell / nix build
        packages.default = umons-latex;

        # Nix develop
        devShells.default = pkgs.mkShellNoCC {
          name = "latex-umons-devShell";
          buildInputs = [
            tex
            pkgs.pandoc
            pkgs.nixpkgs-fmt
            pkgs.nixfmt
          ];
        };
      });
}
