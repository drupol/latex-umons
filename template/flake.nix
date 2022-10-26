{
  description = "UMons document";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    latex-umons.url = "github:drupol/latex-umons";
  };

  outputs = { self, nixpkgs, flake-utils, latex-umons, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        version = self.shortRev or self.lastModifiedDate;

        pkgs = import nixpkgs {
          inherit system;

          overlays = [
            latex-umons.overlays.default
          ];
        };

        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-full latex-bin latexmk;
          latex-umons = {
            pkgs = [ pkgs.latex-umons ];
          };
        };
      in
      {
        packages.presentation = pkgs.stdenvNoCC.mkDerivation {
          name = "umons-presentation";

          src = self;

          buildInputs = [
            tex
            pkgs.gnumake
            pkgs.pandoc
          ];

          buildPhase = ''
            make build-presentation
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out
            cp presentation.pdf $out/

            runHook postInstall
          '';
        };

        packages.document = pkgs.stdenvNoCC.mkDerivation {
          name = "umons-document";

          src = self;

          buildInputs = [
            tex
            pkgs.gnumake
            pkgs.pandoc
          ];

          buildPhase = ''
            make build-document
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out
            cp document.pdf $out/

            runHook postInstall
          '';
        };

        # Nix develop
        devShells.default = pkgs.mkShellNoCC {
          name = "umons-document-devshell";
          buildInputs = [
            tex
            pkgs.gnumake
            pkgs.pandoc
            pkgs.nixpkgs-fmt
            pkgs.nixfmt
          ];
        };
      });
}
