# UMons LaTeX

This repository contains a beamer theme and various LaTeX classes that are
primarily intended to be used by professors and students of the university of
Mons but may also be of interest to a larger audience.

It also contains a flake file for facilitating the integration into your own
document using Nix.

Original work by Christophe Troestler at https://github.com/Chris00/latex-umons

## LaTeX Classes

- A Beamer theme `UMONS`,
- `exercice-umons.cls` is a class to write regular document with proper header.
- `memoire-umons.cls` is a simple class to write a master's thesis.
- `tests.cls` aims to provide a simple way of composing tests.  One or
  more tests may be in the same file (in case, say, they share
  questions).
- `exprog.cls` is an class to write homework.
- `letter-umons.cls` is a class to write letters according to the UMONS layout.

## Quick start

Quickly create a PDF document with Markdown using the following command:

```shell
nix run github:drupol/latex-umons -- /path/to/your/file.md
open pandoc-exercice-umons.pdf
```

## Installation

### Installation with Nix

The easiest way to use this project is to [install Nix][install nix].
Once installed, you must enable the `flake` feature,
[follow the tutorial][nix flake wiki] to do so.

This project provides a template to get you started quickly.

To instantiate a blank project containing all the required files:

```shell
nix flake new --template github:drupol/latex-umons /your/new-project/path
```

Once installed, go in the new directory and run the following command to build
the document:

```shell
nix build .#document
open result/document.pdf
```

Run the following command to build the presentation:

```shell
nix build .#presentation
open result/presentation.pdf
```

### Installation without Nix

There are multiple ways to install this project. One of the practical
ways to install it is to install once and use it in any of your document without
duplicating files.

First, you must clone this repository in a place of yours and then do:

```shell
make install
```

To verify that it has been correctly installed, run:

```shell
kpsewhich beamerthemeUMONS.sty
```

The return of that command should be a full path to the file, meaning that the
theme has been correctly installed.

## Demo

Every time a commit is made in this repository, new PDFs are generated and added
to a Github pre-release.

Visit the [latest release][latest release] to check them out.

## API

This package is contains a `flake.nix` which exposes its derivations in an
[overlay][nix overlays].

Exposed derivations:
- `latex-umons`: The LaTeX classes
- `pandoc-template-umons`: The Pandoc beamer template

To use it in your own package, take example on the following minimum working
example:

```nix
{
  description = "Simple flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    latex-umons.url = "github:drupol/latex-umons";
  };

  outputs = { self, nixpkgs, flake-utils, latex-umons, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          overlays = [
            latex-umons.overlays.default
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
      in
      {
        devShells.default = pkgs.mkShellNoCC {
          name = "devshell";

          buildInputs = [
            tex
            pandoc
          ];
        };
      });
}
```

[install nix]: https://nixos.org/download.html
[nix flake wiki]: https://nixos.wiki/wiki/Flakes
[latest release]: https://github.com/drupol/latex-umons/releases/latest
[nix overlays]: https://nixos.wiki/wiki/Overlays
