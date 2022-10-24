{
  description = "Umons LaTeX";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      overlay-latex-umons = nixpkgs: final: prev: {
        umons-latex = prev.stdenv.mkDerivation {
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
      };
    in
    {
      overlays.default = (overlay-latex-umons nixpkgs.outPath);
    } //
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [
          self.overlays.default
        ];

        pkgs = import nixpkgs {
          inherit overlays system;
        };

        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-full latex-bin latexmk;

          umons-latex = {
            pkgs = [ pkgs.umons-latex ];
          };
        };
      in
      {
        # Nix shell / nix build
        packages.default = pkgs.umons-latex;

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
