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

      # nix flake new --template templates#default ./my-new-document
      templates.default = {
        path = ./template;
        description = "A template for creating PDF document with UMons theme with Pandoc or LaTeX.";
      };
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

        presentation = pkgs.stdenvNoCC.mkDerivation {
          name = "umons-presentation";

          src = self;

          buildInputs = [
            tex
            pkgs.gnumake
            pkgs.pandoc
          ];

          buildPhase = ''
            make -C template build-presentation
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out
            cp template/presentation.pdf $out/

            runHook postInstall
          '';
        };

        document = pkgs.stdenvNoCC.mkDerivation {
          name = "umons-document";

          src = self;

          buildInputs = [
            tex
            pkgs.gnumake
            pkgs.pandoc
          ];

          buildPhase = ''
            make -C template build-document
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out
            cp template/document.pdf $out/

            runHook postInstall
          '';
        };

        exprog = pkgs.stdenvNoCC.mkDerivation {
          name = "umons-exprog";

          src = self;

          buildInputs = [
            tex
            pkgs.gnumake
            pkgs.pandoc
          ];

          buildPhase = ''
            make -C template build-exprog
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out
            cp template/exprog.pdf $out/

            runHook postInstall
          '';
        };
      in
      {
        packages.document = document;
        packages.exprog = exprog;
        packages.presentation = presentation;

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

        checks.document = document;
        checks.exprog = exprog;
        checks.presentation = presentation;
      });
}
