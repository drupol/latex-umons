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
              make build-${name}
            '';

            installPhase = ''
              runHook preInstall

              mkdir -p $out
              cp ${name}.pdf $out/

              runHook postInstall
            '';
          }
        );
      in
      {
        # Nix shell / nix build
        packages = documentTypes // {
          "default" = documentTypes.document;
        };

        # Nix develop
        devShells.default = pkgs.mkShellNoCC {
          name = "umons-document-devshell";
          buildInputs = [
            tex
            pandoc
            pkgs.gnumake
            pkgs.nixpkgs-fmt
            pkgs.nixfmt
          ];
        };
      });
}
