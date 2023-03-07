{
  description = "Umons LaTeX";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-filter.url = github:numtide/nix-filter;
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = inputs.nixpkgs.lib.systems.flakeExposed;
      flake = let
        overlay-latex-umons = nixpkgs: final: prev: {
          latex-umons = prev.stdenvNoCC.mkDerivation {
            name = "latex-umons";
            pname = "latex-umons";
            src = inputs.nix-filter.lib.filter {
              root = ./.;
              exclude = [./template];
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
          pandoc-template-umons = prev.stdenvNoCC.mkDerivation {
            name = "pandoc-template-umons";
            pname = "pandoc-template-umons";
            src = inputs.nix-filter.lib.filter {
              root = ./.;
              exclude = [./template];
            };

            dontBuild = true;

            installPhase = ''
              runHook preInstall

              mkdir -p $out
              cp -ar $src/src/pandoc/* $out/

              runHook postInstall
            '';
          };
        };
      in {
        overlays.default = overlay-latex-umons inputs.nixpkgs;

        # nix flake new --template templates#default ./my-new-document
        templates.default = {
          path = ./template;
          description = "A template for creating PDF document with UMons theme with Pandoc or LaTeX.";
        };
      };

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        pkgs = import inputs.nixpkgs {
          overlays = [
            inputs.self.overlays.default
          ];
          inherit system;
        };

        pandoc = pkgs.writeShellScriptBin "pandoc" ''
          ${pkgs.pandoc}/bin/pandoc --data-dir ${pkgs.pandoc-template-umons} $@
        '';

        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive)
            scheme-full
            latex-bin
            latexmk
            lettrine
            ;

          latex-umons = {
            pkgs = [pkgs.latex-umons];
          };
        };

        documentNames = [
          "document"
          "exprog"
          "memoire"
          "presentation"
        ];

        documentTypes = inputs.nixpkgs.lib.genAttrs documentNames (
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
                runHook preBuild

                make -C template build-${name}

                runHook postBuild
              '';

              installPhase = ''
                runHook preInstall

                mkdir -p $out
                cp template/${name}.pdf $out/

                runHook postInstall
              '';
            }
        );

        pandoc-exercice-umons = pkgs.writeShellApplication {
          name = "pandoc-exercice-umons";
          text = ''
            ${pkgs.pandoc}/bin/pandoc --from markdown --to latex -s --template=${pkgs.pandoc-template-umons}/templates/umons.latex -o pandoc-exercice-umons.pdf "$@"
          '';
          runtimeInputs = [tex];
        };
      in {
        formatter = pkgs.alejandra;

        # Nix shell / nix build
        packages =
          documentTypes
          // {
            default = pkgs.latex-umons;
            pandoc-exercice-umons = pandoc-exercice-umons;
          };

        # Nix develop
        devShells.default = pkgs.mkShellNoCC {
          name = "latex-umons-devShell";
          buildInputs = [
            tex
            pandoc
          ];
        };

        checks = documentTypes;
      };
    };
}
