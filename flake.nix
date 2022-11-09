{
  description = "Umons LaTeX";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = github:numtide/nix-filter;
  };

  outputs = { self, nixpkgs, flake-utils, nix-filter, ... }@inputs:
    let
      overlay-latex-umons = nixpkgs: final: prev: {
        latex-umons = prev.stdenv.mkDerivation {
          name = "latex-umons";
          pname = "latex-umons";
          src = nix-filter.lib.filter {
            root = ./.;
            exclude = [ ./template ];
          };

          dontBuild = true;

          installPhase = ''
            runHook preInstall

            mkdir -p $out/tex/latex/umons
            cp -ar $src/src/latex/* $out/tex/latex/umons

            runHook postInstall
          '';

          tlType = "run";
        };
        pandoc-template-umons = prev.stdenv.mkDerivation {
          name = "pandoc-template-umons";
          pname = "pandoc-template-umons";
          src = nix-filter.lib.filter {
            root = ./.;
            exclude = [ ./template ];
          };

          dontBuild = true;

          installPhase = ''
            runHook preInstall

            mkdir -p $out/templates
            cp -ar $src/src/pandoc/* $out/templates/

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
        pkgs = import nixpkgs {
          overlays = [
            self.overlays.default
          ];
          inherit system;
        };

        pandoc = pkgs.writeShellScriptBin "pandoc" ''
          ${pkgs.pandoc}/bin/pandoc --data-dir ${pkgs.pandoc-template-umons} $@
        '';

        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-full latex-bin latexmk;

          latex-umons = {
            pkgs = [ pkgs.latex-umons ];
          };
        };

        documentNames = [
          "document"
          "exprog"
          "memoire"
          "presentation"
        ];

        documentTypes = nixpkgs.lib.genAttrs documentNames (
          name:
          pkgs.stdenvNoCC.mkDerivation {
            name = "umons-" + name;

            src = pkgs.lib.cleanSource ./.;

            buildInputs = [
              tex
              pandoc
              pkgs.gnumake
            ];

            buildPhase = ''
              make -C template build-${name}
            '';

            installPhase = ''
              runHook preInstall

              mkdir -p $out
              cp template/${name}.pdf $out/

              runHook postInstall
            '';
          }
        );
      in
      {
        # Nix shell / nix build
        packages = documentTypes // {
          "default" = pkgs.latex-umons;
        };

        # Nix develop
        devShells.default = pkgs.mkShellNoCC {
          name = "latex-umons-devShell";
          buildInputs = [
            tex
            pandoc
            pkgs.nixpkgs-fmt
            pkgs.nixfmt
          ];
        };

        checks = documentTypes;
      });
}
