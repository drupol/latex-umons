# European Commission LaTeX Beamer theme

## Documentation

### Pandoc template

To generate a presentation with Pandoc, create a markdown file
`presentation.md`:

```markdown
---
title: "My wonderful presentation"
author: "Author name"
date: date
institute: "Institute name"
documentclass: beamer
beamer: true
theme: "ec"
notes: true
---

# General information

## Themes, fonts, etc.

- I use default **pandoc** themes.
- This presentation is made with **Frankfurt** theme and **beaver** color theme.
- I like **professionalfonts** font scheme.
```

Then, to generate the presentation in PDF, run:

```shell
pandoc src/presentation.md --from markdown --slide-level 2 --shift-heading-level=0 -s --to=beamer --template src/templates/beamer.latex -o presentation.pdf
```

Find a presentation example in the `examples` directory.

### Installation

There are multiple ways to install a LaTeX beamer theme. One of the practical
ways to install it is to install once and use it in any of your document without
duplicating files.

To install the European Commission (EC) theme, you must clone this repository
in a place of yours and then do:

```shell
make install
```

To verify that it has been correctly installed, run:

```shell
kpsewhich beamerthemeec.sty
```

The return of that command should be a full path to the file, meaning that the
EC theme has been correctly installed.

### Installation with Nix

When using Nix flake to build LaTeX document, you can use this repository as a
flake input and build a customized version of Texlive including this theme.

The current project provides a Nix overlay through its flake file.

To use this theme in your document, `theme-ec` must be an input of your own
flake file as such:

```nix
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    theme-ec.url = "git+https://code.europa.eu/pol/european-commission-latex-beamer-theme/";
  };
```

Then, build `pkgs` using the default overlay:

```nix
    pkgs = import nixpkgs
    {
        overlays = [
            theme-ec.overlays.default
        ];

        inherit system;
    };

```

And then, you can use the package `latex-theme-ec` to build the `tex`
derivation:

```nix
    tex = pkgs.texlive.combine {
        inherit (pkgs.texlive) scheme-full latex-bin latexmk;
        latex-theme-ec = {
            pkgs = [ pkgs.latex-theme-ec ];
        };
    };
```

To verify that it has been correctly installed, run:

```shell
kpsewhich beamerthemeec.sty
```

The return of that command should be a full path to the file, meaning that the
EC theme has been correctly installed.
