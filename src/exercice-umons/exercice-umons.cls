\NeedsTeXFormat{LaTeX2e}[1998/12/01]
\ProvidesClass{exercice-umons}[2009/05/05 v0.1 ^^J
  \space
  Exercices de l'Université de Mons.]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%                            O P T I O N S
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Option "print" to disable the colors for the
\newif\ifumons@print \umons@printfalse
\DeclareOption{print}{\umons@printtrue}

\newif\ifumons@draft \umons@draftfalse
\DeclareOption{draft}{%
  \umons@drafttrue
  \PassOptionsToClass{draft}{book}}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}

\ProcessOptions
\LoadClass{book}

% \addtolength{\textwidth}{2cm}
% \addtolength{\oddsidemargin}{-1cm}
% \addtolength{\textheight}{2cm}
% \setlength{\parindent}{0pt}

\RequirePackage{amsthm,aliascnt}
\RequirePackage{amssymb}
\RequirePackage{translator}
\RequirePackage{graphics}

% For the logos (use `xcolor' to avoid warnings if `xcolor' is used in
% the document, e.g. with Tikz).  `xcolor' is not present in all distrib.
%\PassOptionsToPackage{rgb}{xcolor}
\AtBeginDocument{%
  \IfFileExists{xcolor.sty}{%
    \RequirePackage{xcolor}}{%
    \RequirePackage{color}}%

  \definecolor{umonsgreen}{rgb}{0.56862745,0.78039216,0.63137255}
  \definecolor{umonsdarkgreen}{rgb}{0.4,0.47,0.42}
  \definecolor{umonsblue}{rgb}{0.23,0.85,0.98}
  \definecolor{umonsdarkblue}{rgb}{0.23,0.33,0.95}
  \definecolor{umonsmetalblue}{rgb}{0.21,0.67,0.61}
  \definecolor{umonsred}{RGB}{168, 0, 57}
  \definecolor{umonsgray}{RGB}{150, 150, 150}
  \definecolor{umonsturquoise}{RGB}{0, 171, 204}
}

\ifumons@draft
\setlength{\overfullrule}{10pt}
%\errorcontextlines=10 % debugging
\fi

%% Compatibility

\@ifundefined{AddToHook}{%
  \RequirePackage{etoolbox}
  \let\umons@AfterBeginDocument=\AfterEndPreamble
}{
  \newcommand*{\umons@AfterBeginDocument}[1]{%
    \AddToHook{begindocument/end}{#1}}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%                              P D F
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\AtBeginDocument{%
  \@ifundefined{hypersetup}{}{%
    \hypersetup{%
      pdftitle={\@title},%
      pdfauthor={\@author\space (University of Mons)},%
      pdfsubject={Master's Thesis},%
      %pdfkeywords={},
      plainpages=false, % => page.i <> page.1
      colorlinks=true,
      pdfstartview=FitH,
      % pdfmenubar=false
    }%
    \ifumons@print
    \hypersetup{%
      urlcolor=black,
      citecolor=black,
      linkcolor=black,
    }%
    \else
    \hypersetup{%
      urlcolor=umonsdarkgreen,
      citecolor=umonsdarkblue,
      linkcolor=umonsred,
    }%
    \fi
  }}

\newif\ifpdf@umons
\@ifundefined{pdfoutput}{%
  \pdf@umonsfalse
}{%
  \ifnum\pdfoutput<1 % => not generating pdf
    \pdf@umonsfalse
  \else
    \pdf@umonstrue
  \fi
}

\ifpdf@umons\else
\providecommand{\Hy@colorlink}[1]{}
\providecommand{\Hy@endcolorlink}{}
\fi

\AtBeginDocument{\providecommand{\texorpdfstring}[2]{#1}}

\AtBeginDocument{%
  \translatelet{\@discipline}{Informatics}
  \translatelet{\@departement}{Department of}
  \translatelet{\memoire@faculte}{Faculty of Sciences}
  \translatelet{\memoire@universite}{University of Mons}
}

\begingroup
\catcode`\:=\active
\gdef\umons@activecolon{:}% For e.g. French (or other languages)
\gdef:{\string:}% Default value of the macro
\endgroup

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%                    P A G E   D E   G A R D E
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\def\umons@service{}
\newcommand{\service}[1]{%
  \def\umons@service{#1}%
  \translatelet{\@service@name}{Service}}
\newcommand{\services}[1]{%
  \def\umons@service{#1}%
  \translatelet{\@service@name}{Services}}
\newcommand{\departement}[1]{%
  \def\umons@departement{#1}%
  \translatelet{\@departement@name}{Department of}}

\newcommand{\discipline}[1]{\def\@discipline{#1}}
\def\@date{}

\def\umons@logofac{UMONS_FS}
\newcommand{\logofac}[1]{\def\umons@logofac{#1}}

\newcommand{\umons@notempty}[3]{{%
    \def\\{}% (locally)
    \ifx #1\empty \PackageError{exercice-umons}{%
      Pas de #2.^^J\space\space Utilisez la commande `\protect
      #3{...}'  pour specifier sa valeur}{}%
    \fi }}

\newcommand{\bottomsep}{%
  \hspace{0.5em}\raisebox{0.1ex}{\rotatebox{45}{\rule{0.7ex}{0.7ex}}}%
  \hspace{0.5em}\ignorespaces}

\renewcommand{\maketitle}{%
  \renewcommand{\thepage}{\Roman{page}}% => no clash for PDF links
  % Checks:
  \umons@notempty{\@date}{d'annee academique}{\date}%
  \umons@notempty{\@departement}{departement}{\departement}%
  \begin{titlepage}
    % Le logo DOIT être en haut à droite du document
    \addtolength{\hoffset}{5mm}% recenter slightly (local to this page)
    \noindent
    \smash{\raisebox{13mm}{\hbox to \textwidth{%
          \hspace{-8mm}%
          % \resizebox{!}{15mm}{\includegraphics{Sciences-gray}}%
          \fontfamily{phv}\fontsize{9}{12}\selectfont
          % http://dante.ctan.org/CTAN/fonts/winfonts/
          % \fontfamily{verdana}\selectfont
          \color{umonsgray}
          %\ifpdf@umons
          \begin{tabular}[t]{@{}l@{}}
            % \resizebox{!}{20mm}{\includegraphics{lorentz}}\\[-5mm]
            \ifx \umons@logofac\empty \else
              \resizebox{!}{15mm}{\includegraphics{\umons@logofac}}\\[3pt]%
            \fi
            \@departement@name\ \umons@departement
          \end{tabular}%
          %\fi
          \hfill
          % \vrule width 0.3pt height 11mm depth 4mm % (test)
          %\raisebox{-3.6mm}{% Sciences
          \raisebox{0mm}{%
            \resizebox{!}{15mm}{\includegraphics{UMONS+txt}}
            %\resizebox{!}{15mm}{\includegraphics{UMONS}}
            % To adjust elements visually:
            %\llap{\raisebox{3mm}{\vrule width 30cm height 0pt depth 0.3pt}}%
            %\llap{\raisebox{15mm}{\vrule width 30cm height 0pt depth 0.3pt}}%
          }%
          \hspace{-24mm}%
        }}}%
    \vspace{10em}
    \begin{center}
      \vspace{-5mm}
      {\bfseries\sffamily
        \fontsize{30}{40}\fontfamily{phv}\selectfont % Helvetica
        \@title
        \\[1.5ex]}%
      \fontsize{12}{14}\fontfamily{ptm}\selectfont %

      \vfill
      \begin{tabular}[t]{@{}r@{ }l@{}}
        \ifx \umons@service\empty \else
        \textbf{\@service@name\umons@activecolon}&
        \begin{tabular}[t]{@{}l@{}} \umons@service \end{tabular}%
        \fi
        \\[2\jot]
        \ifx \@author\empty \else
        \textbf{Author\umons@activecolon}&
        \begin{tabular}[t]{@{}l@{}} \@author \end{tabular}%
        \fi
      \end{tabular}
      \\
      \vfill\vfill\vfill
      \translate{Academic Year} \@date\par
      \vfill
      \smash{\raisebox{-23mm}{\vtop{%
            %\centerline{\resizebox{!}{15mm}{\includegraphics{Acad-logoumh}}}
            \memoire@faculte\bottomsep
            \memoire@universite\bottomsep
            Place du Parc 20\bottomsep
            B-7000 Mons %(Belgium)
          }}}%
    \end{center}
  \end{titlepage}
  \newpage
  \thispagestyle{empty}
  \null % No content
  \newpage
  % Roman numbered pages:
  \setcounter{page}{1}%
  \renewcommand{\thepage}{\arabic{page}}%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%                              T O C
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\renewcommand{\tableofcontents}{%
  \if@twocolumn \@restonecoltrue \onecolumn \else \@restonecolfalse\fi
  \chapter*{\contentsname
    \@mkboth {\textsl{\contentsname}}{%
      \textsl{\contentsname}}}%
  \@starttoc {toc}\if@restonecol \twocolumn \fi
  \newpage
  \@mkboth{}{}% many students do not understand what happens otherwise...
}

% Redefine the numering of content lines because the Roman numbering
% may go into the text.
\renewcommand{\numberline}[1]{%
  % \@tempdima contains the width of the box for the number.
  \settowidth{\@tempdimb}{#1\hspace{0.8ex}}%
  \ifdim \@tempdimb > \@tempdima  {#1}\hspace{1ex}%
  \else  \hb@xt@ \@tempdima {#1\hfil}%
  \fi}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%                          P R E F A C E
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newenvironment{preface}{%
  % Pages for the document:
  \ifnum \value{page} > 1
  \PackageError{exercice-umons}{%
    L'environnement `preface' doit commencer en page 1.}{}%
  \fi
  \renewcommand{\thepage}{\roman{page}}%
}{%
  \newpage
  % Pages for the document:
  \setcounter{page}{1}%
  \renewcommand{\thepage}{\arabic{page}}%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%                       C H A P T E R S ...
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\renewcommand{\thechapter}{\Roman{chapter}}
\renewcommand{\thesection}{%
  \ifnum\value{chapter}>0 \thechapter .\fi
  \arabic{section}}

\renewcommand{\@makechapterhead}[1]{%
  \vspace*{50\p@}{%
    \parindent \z@
    \raggedright \normalfont \sffamily
    \ifnum \c@secnumdepth >\m@ne
      \if@mainmatter
        \huge \bfseries \@chapapp \space \thechapter \par
        \nobreak \vskip 20\p@
      \fi
    \fi
    \interlinepenalty \@M
    \Huge \bfseries #1\par
    \nobreak \vskip 40\p@}}

\renewcommand{\@makeschapterhead}[1]{%
  \vspace*{50\p@ }{%
    \parindent \z@
    \raggedright \normalfont \sffamily
    \interlinepenalty \@M
    \Huge \bfseries #1\par
    \nobreak \vskip 40\p@}}

\renewcommand{\chaptermark}[1]{%
  \markboth{\textsl{\@chapapp \space \thechapter\ ---\ #1}}{%
    \textsl{\@chapapp \space \thechapter\ ---\ #1}}}

\renewcommand{\section}{%
  \@startsection {section}{1}{\z@ }{%
    -3.5ex \@plus -1ex \@minus -.2ex}{%
    2.3ex \@plus .2ex}{%
    \normalfont \Large \sffamily\bfseries }}

\renewcommand{\sectionmark}[1]{%
  \markright{\thesection\ ---\ #1}}

\renewcommand{\subsection}{%
  \@startsection {subsection}{2}{\z@ }{%
    -3.25ex\@plus -1ex \@minus -.2ex}{%
    1.5ex \@plus .2ex}{%
    \normalfont \large \sffamily\bfseries }}

\renewcommand{\subsubsection}{%
  \@startsection {subsubsection}{3}{\z@ }{%
    -3.25ex\@plus -1ex \@minus -.2ex}{%
    1.5ex \@plus .2ex}{%
    \normalfont \normalsize\sffamily \bfseries }}

\renewcommand{\paragraph}{%
  \@startsection {paragraph}{4}{\z@ }{%
    3.25ex \@plus 1ex \@minus .2ex}{-1em}{%
    \normalfont \normalsize \sffamily\bfseries }}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%                           Theorems,...
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Be compatible with \autoref (provided by hyperref)

\newtheorem{theorem}{\translate{Theorem}}[chapter]
\umons@AfterBeginDocument{% Do nor capitalize in French
  \def\theoremautorefname{\translate{umons@Theorem}}}

\newaliascnt{proposition}{theorem}
\newtheorem{proposition}[proposition]{\translate{Proposition}}
\aliascntresetthe{proposition}
\providecommand*{\propositionautorefname}{\translate{umons@Proposition}}

\newaliascnt{lemma}{theorem}
\newtheorem{lemma}[lemma]{\translate{Lemma}}
\aliascntresetthe{lemma}
\providecommand*{\lemmaautorefname}{\translate{umons@Lemma}}

\newaliascnt{corollary}{theorem}
\newtheorem{corollary}[corollary]{\translate{Corollary}}
\aliascntresetthe{corollary}
\providecommand*{\corollaryautorefname}{\translate{umons@Corollary}}

\theoremstyle{definition}

\newaliascnt{definition}{theorem}
\newtheorem{definition}[definition]{\translate{Definition}}
\aliascntresetthe{definition}
\providecommand*{\definitionautorefname}{\translate{umons@Definition}}

\theoremstyle{remark}

\newaliascnt{remark}{theorem}
\newtheorem{remark}[remark]{\translate{Remark}}
\aliascntresetthe{remark}
\providecommand*{\remarkautorefname}{\translate{umons@Remark}}


\umons@AfterBeginDocument{%
  \providecommand{\equationname}{\translate{umons@Equation}}%
  \def\equationautorefname~#1\null{%
    \equationname~(#1)\null}
}
