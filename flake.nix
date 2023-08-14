{
  description = "Umons LaTeX";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-filter.url = "github:numtide/nix-filter";
    systems.url = "github:nix-systems/default";
  };

  outputs = inputs@{ self, flake-parts, systems, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import systems;

    flake = {
      overlays.default = final: prev: {
        latex-umons = prev.stdenvNoCC.mkDerivation (finalAttrs: {
          name = "latex-umons";
          pname = "latex-umons";
          version = "1.0.0";

          src = inputs.nix-filter.lib.filter {
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

          passthru = {
            pkgs = [ finalAttrs.finalPackage ];
            tlType = "run";
          };
        });

        pandoc-template-umons = prev.stdenvNoCC.mkDerivation {
          name = "pandoc-template-umons";
          pname = "pandoc-template-umons";
          src = inputs.nix-filter.lib.filter {
            root = ./.;
            exclude = [ ./template ];
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

      # nix flake new --template templates#default ./my-new-document
      templates.default = {
        path = ./template;
        description = "A template for creating PDF document with UMons theme with Pandoc or LaTeX.";
      };
    };

    perSystem = { config, self', inputs', pkgs, system, lib, ... }:
      let
        pkgs = import inputs.nixpkgs {
          overlays = [
            inputs.self.overlays.default
          ];
          inherit system;
        };

        pandoc = pkgs.writeShellApplication {
          name = "pandoc";
          text = ''
            ${lib.getExe pkgs.pandoc} \
              --data-dir=${pkgs.pandoc-template-umons} \
              "$@"
          '';
          runtimeInputs = [ tex ];
        };

        tex = pkgs.texlive.combine {
          inherit
            (pkgs.texlive)
            scheme-full
            latex-bin
            latexmk
            lettrine
            ;

          latex-umons = {
            pkgs = [ pkgs.latex-umons ];
          };
        };

        documentsConfig = [
          {
            name = "exercice-umons";
            directory = "exercice-umons";
            pandocArguments = [ ];
          }
          {
            name = "exprog";
            directory = "exprog";
            pandocArguments = [ ];
          }
          {
            name = "memoire-umons";
            directory = "memoire-umons";
            pandocArguments = [ ];
          }
          {
            name = "presentation";
            directory = "presentation";
            pandocArguments = [
              "--slide-level=2"
              "--shift-heading-level=0"
              "--to=beamer"
            ];
          }
        ];

        umons-pandoc-app = pkgs.writeShellApplication {
          name = "umons-pandoc-app";
          text = ''
            ${lib.getExe pkgs.pandoc} \
              --standalone \
              --to=latex \
              --template=${pkgs.pandoc-template-umons}/templates/umons.latex \
              "$@"
          '';
          runtimeInputs = [ tex ];
        };

        watch-umons-pandoc-app = pkgs.writeShellApplication {
          name = "watch-umons-pandoc-app";
          text = ''
            export TEXINPUTS="${./.}//:"

            echo "Now watching for changes and building it..."

            while true; do \
              ${lib.getExe umons-pandoc-app} "$@"
              ${pkgs.inotify-tools}/bin/inotifywait --exclude '\.pdf|\.git' -qre close_write .; \
            done
          '';
          runtimeInputs = [ tex ];
        };

        documentTypes =
          inputs.nixpkgs.lib.foldl
            (carry: config:
              carry
              // {
                "${config.name}" = pkgs.stdenvNoCC.mkDerivation {
                  name = "umons-${config.name}";

                  src = pkgs.lib.cleanSource ./.;

                  TEXINPUTS = "${./.}//:";

                  buildPhase =
                    let
                      pandocOptions = inputs.nixpkgs.lib.concatStrings (
                        map
                          (argument: "${argument} ")
                          config.pandocArguments
                      );
                    in
                    ''
                      runHook preBuild

                      ${lib.getExe umons-pandoc-app} \
                        --pdf-engine=latexmk \
                        --citeproc \
                        --from=markdown \
                        --output=${config.name}.pdf \
                        ${pandocOptions} \
                        $src/template/src/${config.directory}/*.md

                      runHook postBuild
                    '';

                  installPhase = ''
                    runHook preInstall

                    mkdir -p $out
                    cp ${config.name}.pdf $out/

                    runHook postInstall
                  '';
                };
              })
            { }
            documentsConfig;

        watcherApps =
          inputs.nixpkgs.lib.foldl
            (carry: config:
              carry
              // {
                "watch-${config.name}" = {
                  type = "app";
                  program = pkgs.writeShellApplication {
                    name = "watch-umons-pandoc-${config.name}-app";
                    text =
                      let
                        pandocOptions = inputs.nixpkgs.lib.concatStrings (
                          map
                            (argument: "${argument} ")
                            config.pandocArguments
                        );
                      in
                      ''
                        export TEXINPUTS="${./.}//:"

                        echo "Now watching for changes and building it..."

                        while true; do \
                          ${lib.getExe umons-pandoc-app} \
                            ${pandocOptions} \
                            "$@"
                          ${pkgs.inotify-tools}/bin/inotifywait --exclude '\.pdf|\.git' -qre close_write .; \
                        done
                      '';
                  };
                };
              })
            { }
            documentsConfig;
      in
      {
        formatter = pkgs.alejandra;

        # nix run
        apps =
          watcherApps
          // {
            pandoc = {
              type = "app";
              program = umons-pandoc-app;
            };
          }
          // {
            watch = {
              type = "app";
              program = watch-umons-pandoc-app;
            };
          }
          // {
            pandoc-exercice-umons = {
              type = "app";
              program = throw "Please update your command, 'pandoc-exercice-umons' has been renamed into 'pandoc'.";
            };
          };

        # Nix shell / nix build
        packages = documentTypes;

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
