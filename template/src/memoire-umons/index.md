---
author: "Author name"
date: 2022-2023
documentclass: memoire-umons
title: Memoire title
subtitle: Memoire subtitle
directeur: Mr John Doe
service: Service
biblatex: true
biblio-title: Bibliography title
bibliography:
- template/src/memoire-umons/ref.bib
csquotes: true
graphics: true
# reference-section-title: Bibliography title
# link-citations: true
# link-bibliography: true
# references:
# - type: article-journal
#   id: WatsonCrick1953
#   author:
#   - family: Watson
#     given: J. D.
#   - family: Crick
#     given: F. H. C.
#   issued:
#     date-parts:
#     - - 1953
#       - 4
#       - 25
#   title: 'Molecular structure of nucleic acids: a structure for
#     deoxyribose nucleic acid'
#   title-short: Molecular structure of nucleic acids
#   container-title: Nature
#   volume: 171
#   issue: 4356
#   page: 737-738
#   DOI: 10.1038/171737a0
#   URL: https://www.nature.com/articles/171737a0
#   language: en-GB
---

\chapter{Chapter one}

# General information

## Themes, fonts, etc.

- I use default **pandoc** themes\footfullcite{einstein}.
- This presentation is made with **Frankfurt** theme and **beaver** color theme.
- I like **professionalfonts** font scheme.

## Links

- Matrix of beamer themes: [https://hartwork.org/beamer-theme-matrix/](https://hartwork.org/beamer-theme-matrix/)
- Font themes: [http://www.deic.uab.es/~iblanes/beamer_gallery/index_by_font.html](http://www.deic.uab.es/~iblanes/beamer_gallery/index_by_font.html)
- Nerd Fonts: [https://nerdfonts.com](https://nerdfonts.com)

\chapter{Chapter two}

# Formatting

## Text formatting

Normal text.
_Italic text_ and **bold text**.
~~Strike out~~ is supported.

## Notes

> This is a note.
>
> > Nested notes are not supported.
> > And it continues.

## Blocks

### This is a block A

- Line A
- Line B

###

New block without header.

### This is a block B.

- Line C
- Line D

## Listings

Listings out of the block.

```sh
#!/bin/bash
echo "Hello world!"
echo "line"
```

### Listings in the block.

```sh
#!/bin/bash
echo "Hello world!"
echo "line"
```

## Table

| **Item** |    **Description** | **Q-ty** |
| :------- | -----------------: | :------: |
| Item A   | Item A description |    2     |
| Item B   | Item B description |    5     |
| Item C   |                N/A |   100    |

## Single picture

This is how we insert picture. Caption is produced automatically from the alt text.

## Two or more pictures in a raw

Here are two pictures in the raw. We can also change two pictures size (height or width).

###

## Lists

1. Idea 1
2. Idea 2
   - genius idea A
   - more genius 2
3. Conclusion

## Two columns of equal width

::: columns

:::: column

Left column text.

Another text line.

::::

:::: column

- Item 1.
- Item 2.
- Item 3.

::::

:::

## Two columns of with 40:60 split

::: columns

:::: {.column width=40%}

Left column text.

Another text line.

::::

:::: {.column width=60%}

- Item 1.
- Item 2.
- Item 3.

::::

:::

## Three columns with equal split

::: columns

:::: column

Left column text.

Another text line.

::::

:::: column

Middle column list:

1. Item 1.
2. Item 2.

::::

:::: column

Right column list:

- Item 1.
- Item 2.

::::

:::

## Three columns with 30:40:30 split

::: columns

:::: {.column width=30%}

Left column text.

Another text line.

::::

:::: {.column width=40%}

Middle column list:

1. Item 1.
2. Item 2.

::::

:::: {.column width=30%}

Right column list:

- Item 1.
- Item 2.

::::

:::

## Two columns: image and text

::: columns

:::: column

\includegraphics[width=\textwidth]{example-image}

::::

:::: column

Text in the right column.

List from the right column:

- Item 1.
- Item 2.

::::

:::

## Two columns: image and table

::: columns

:::: column

\includegraphics[width=\textwidth]{example-image}

::::

:::: column

| **Item** | **Option** |
| :------- | :--------: |
| Item 1   |  Option 1  |
| Item 2   |  Option 2  |

::::

:::

## Fancy layout

### Proposal

- Point A
- Point B

::: columns

:::: column

### Pros

- Good
- Better
- Best

::::

:::: column

### Cons

- Bad
- Worse
- Worst

::::

:::

### Conclusion

- Let's go for it!
- No way we go for it! -->
