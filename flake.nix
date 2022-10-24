{
  description = "Umons LaTeX";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      overlay-latex-umons = nixpkgs: final: prev: {
        latex-umons = prev.stdenv.mkDerivation {
          name = "latex-umons";
          pname = "latex-umons";
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
      overlays.default = overlay-latex-umons nixpkgs;
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

          latex-umons = {
            pkgs = [ pkgs.latex-umons ];
          };
        };
      in
      {
        # Nix shell / nix build
        packages.default = pkgs.latex-umons;

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
