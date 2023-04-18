{
  description = "UMons documents";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    latex-umons.url = "github:drupol/latex-umons";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    latex-umons,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      version = self.shortRev or self.lastModifiedDate;

      pkgs = import nixpkgs {
        inherit system;

        overlays = [
          latex-umons.overlays.default
        ];
      };

      tex = pkgs.texlive.combine {
        inherit (pkgs.texlive) scheme-full latex-bin latexmk;

        inherit (pkgs) latex-umons;
      };

      pandoc = pkgs.writeShellApplication {
        name = "pandoc";
        text = ''
          ${pkgs.pandoc}/bin/pandoc \
            --data-dir ${pkgs.pandoc-template-umons} \
            "$@"
        '';
        runtimeInputs = [tex];
      };

      pandoc-exercice-umons-app = pkgs.writeShellApplication {
        name = "pandoc-exercice-umons-app";

        text = ''
          ${pkgs.pandoc}/bin/pandoc \
            --standalone \
            --pdf-engine=lualatex \
            --template=${pkgs.pandoc-template-umons}/templates/umons.latex \
            --from=markdown \
            --to=latex \
            "$@"
        '';

        runtimeInputs = [tex];
      };

      pandoc-exprog-app = pkgs.writeShellApplication {
        name = "pandoc-exprog-app";

        text = ''
          ${pkgs.pandoc}/bin/pandoc \
            --standalone \
            --pdf-engine=lualatex \
            --template=${pkgs.pandoc-template-umons}/templates/umons.latex \
            --from=markdown \
            --to=latex \
            "$@"
        '';

        runtimeInputs = [tex];
      };

      pandoc-memoire-umons-app = pkgs.writeShellApplication {
        name = "pandoc-memoire-umons-app";

        text = ''
          ${pkgs.pandoc}/bin/pandoc \
            --standalone \
            --pdf-engine=lualatex \
            --template=${pkgs.pandoc-template-umons}/templates/umons.latex \
            --from=markdown \
            --to=latex \
            "$@"
        '';

        runtimeInputs = [tex];
      };

      pandoc-presentation-app = pkgs.writeShellApplication {
        name = "pandoc-presentation-app";

        text = ''
          ${pkgs.pandoc}/bin/pandoc \
            --standalone \
            --pdf-engine=lualatex \
            --to=beamer \
            --template=${pkgs.pandoc-template-umons}/templates/umons.latex \
            --slide-level=2 \
            --shift-heading-level=0 \
            "$@"
        '';

        runtimeInputs = [tex];
      };

      pandoc-exercice-umons = pkgs.stdenvNoCC.mkDerivation {
        name = "pandoc-exercice-umons";

        src = pkgs.lib.cleanSource ./.;

        HOME = "$TMPDIR";
        TEXINPUTS = "${./.}//:";
        LC_ALL = "C";

        buildPhase = ''
          ${pandoc-exercice-umons-app}/bin/pandoc-exercice-umons-app \
            --from=markdown \
            --output=exercice-umons.pdf \
            $src/src/exercice-umons/*.md
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out
          cp *.pdf $out/

          runHook postInstall
        '';
      };

      pandoc-exprog = pkgs.stdenvNoCC.mkDerivation {
        name = "pandoc-exprog";

        src = pkgs.lib.cleanSource ./.;

        HOME = "$TMPDIR";
        TEXINPUTS = "${./.}//:";
        LC_ALL = "C";

        buildPhase = ''
          ${pandoc-exprog-app}/bin/pandoc-exprog-app \
            --from=markdown \
            --output=exprog.pdf \
            $src/src/exprog/*.md
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out
          cp *.pdf $out/

          runHook postInstall
        '';
      };

      pandoc-memoire-umons = pkgs.stdenvNoCC.mkDerivation {
        name = "pandoc-memoire-umons";

        src = pkgs.lib.cleanSource ./.;

        HOME = "$TMPDIR";
        TEXINPUTS = "${./.}//:";
        LC_ALL = "C";

        buildPhase = ''
          ${pandoc-memoire-umons-app}/bin/pandoc-memoire-umons-app \
            --output=memoire-umons.pdf \
            $src/src/memoire-umons/*.md
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out
          cp *.pdf $out/

          runHook postInstall
        '';
      };

      pandoc-presentation = pkgs.stdenvNoCC.mkDerivation {
        name = "pandoc-presentation";

        src = pkgs.lib.cleanSource ./.;

        HOME = "$TMPDIR";
        TEXINPUTS = "${./.}//:";
        LC_ALL = "C";

        buildPhase = ''
          ${pandoc-presentation-app}/bin/pandoc-presentation-app \
            --from=markdown \
            --output=presentation.pdf \
            $src/src/presentation/*.md
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out
          cp *.pdf $out/

          runHook postInstall
        '';
      };

      watch-pandoc-exercice-umons-app = pkgs.writeShellApplication {
        name = "watch-pandoc-exercice-umons-app";
        text = ''
          echo "Now watching files for changes..."

          while true; do \
            ${pandoc-exercice-umons-app}/bin/pandoc-exercice-umons-app "$@"
            ${pkgs.inotify-tools}/bin/inotifywait --exclude '\.pdf|\.git' -qre close_write .; \
          done
        '';

        runtimeInputs = [tex];
      };

      watch-pandoc-exprog-app = pkgs.writeShellApplication {
        name = "watch-pandoc-exprog-app";
        text = ''
          echo "Now watching files for changes..."

          while true; do \
            ${pandoc-exprog-app}/bin/pandoc-exprog-app "$@"
            ${pkgs.inotify-tools}/bin/inotifywait --exclude '\.pdf|\.git' -qre close_write .; \
          done
        '';

        runtimeInputs = [tex];
      };

      watch-pandoc-memoire-umons-app = pkgs.writeShellApplication {
        name = "watch-pandoc-memoire-umons-app";
        text = ''
          echo "Now watching files for changes..."

          while true; do \
            ${pandoc-memoire-umons-app}/bin/pandoc-memoire-umons-app "$@"
            ${pkgs.inotify-tools}/bin/inotifywait --exclude '\.pdf|\.git' -qre close_write .; \
          done
        '';

        runtimeInputs = [tex];
      };

      watch-pandoc-presentation-app = pkgs.writeShellApplication {
        name = "watch-pandoc-presentation-app";
        text = ''
          echo "Now watching files for changes..."

          while true; do \
            ${pandoc-presentation-app}/bin/pandoc-presentation-app "$@"
            ${pkgs.inotify-tools}/bin/inotifywait --exclude '\.pdf|\.git' -qre close_write .; \
          done
        '';

        runtimeInputs = [tex];
      };
    in {
      # Nix shell / nix build
      packages = {
        presentation = pandoc-presentation;
        exercice-umons = pandoc-exercice-umons;
        exprog = pandoc-exprog;
        memoire-umons = pandoc-memoire-umons;
      };

      # Nix run
      apps = {
        watch-presentation = {
          type = "app";
          program = watch-pandoc-presentation-app;
        };

        watch-exercice-umons = {
          type = "app";
          program = watch-pandoc-exercice-umons-app;
        };

        watch-exprog = {
          type = "app";
          program = watch-pandoc-exprog-app;
        };

        watch-memoire-umons = {
          type = "app";
          program = watch-pandoc-memoire-umons-app;
        };
      };

      # Nix develop
      devShells.default = pkgs.mkShellNoCC {
        name = "umons-latex-devshell";
        buildInputs = [
          tex
          pandoc
          watch-pandoc-presentation-app
          watch-pandoc-exercice-umons-app
          watch-pandoc-exprog-app
          watch-pandoc-memoire-umons-app
        ];
      };
    });
}
