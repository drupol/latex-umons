# UMons LaTeX

This repository contains a beamer theme and various LaTeX classes that are
primarily intended to be used by professors and students of the university of
Mons but may also be of interest to a larger audience.

It also contains a flake file for facilitating the integration into your own
document using Nix.

Original work Christophe Troestler at https://github.com/Chris00/latex-umons

## LaTeX Classes

- `exercice-umons.cls` is a class to write regular document with proper header.
- `memoire-umons.cls` is a simple class to write a master's thesis.
- `tests.cls` aims to provide a simple way of composing tests.  One or
  more tests may be in the same file (in case, say, they share
  questions).
- `exprog.cls` is an class to write homework.
- `letter-umons.cls` is a class to write letters according to the UMONS layout.

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

[install nix]: https://nixos.org/download.html
[nix flake wiki]: https://nixos.wiki/wiki/Flakes
[latest release]: https://github.com/drupol/latex-umons/releases/latest
