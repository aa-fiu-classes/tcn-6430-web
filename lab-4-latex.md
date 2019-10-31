---
layout: page
title: "Lab 4: LaTeX Basics"
group: "Lab 4"

---

* toc
{:toc}

## Overview

The objective of this lab is to do a last-minute crash course to practice with the features of LaTeX.

LaTeX is a "typesetting" system, meaning that it takes input of text as a program, that includes special commands to define formatting style, section names, labels, etc. and produces the formatted output.
Unlike, MS Word or Google Docs, LaTeX is not "WYSIWYG" (what-you-see-is-what-you-get) system, but with the help of tools, such as [Overleaf](https://overleaf.com), can be almost viewed as such.

Among many advantages of LaTeX, especially for academic papers, are:

- compliance with the formatting without paying attention to formatting details.
  In other words, as a writer, you need to just focus on the content and LaTeX will properly format everything as required by the selected style.

- support for math typesetting. While latest versions of MS Word and others have reasonable support for equations today, they are still treated differently then the text.  With LaTeX, you just need to learn a little bit of a syntax of how to write a formula and everything will be formatted correctly.
  In fact, a lot of apps (including Wikipedia) are using LaTeX formatting for formulas.

- extensive support for cross-referencing. Using `\label{keyword}` one can assign a "label" to almost anything in LaTeX document and then reference to it by simply writing `\ref{keyword}`

- extensive support for bibliography management and referencing.  This is yet another very important feature for academic papers. All you need is to get (download, create manually, create using helper tools) a `.bib` file and reference when needed a paper using `\cite{keyword}` command. Everything else will be handled by LaTeX, including creating `References` section in the document, numbering and sorting references based on the selected style, and adding in-place citation in the selected format.

There are, of course, a few things that are a bit more complex to do in LaTeX, given its nature.  For example, one of the weaknesses are tables.
Of course, you can create them, but it could take much more effort than in WYSIWIG editors.
Dealing with pictures is simple, but not as simple as in Word.
However, you are automatically getting benefits of auto-placement, auto-numbering, and cross-referencing when you use pictures in LaTeX.

If you interested more, there are many LaTeX guides, including:

- [LaTeX Guide](https://www.cs.princeton.edu/courses/archive/spr10/cos433/Latex/latex-guide.pdf)
- [LaTeX crash course](https://github.com/Mageswaran1989/aja/wiki/LaTeX-crash-Course)
- [Overleaf documentation](https://www.overleaf.com/)

## Tasks

### 1. Create Overleaf account

LaTeX is open source framework and you can work with it locally on any device.  [You could just download and install the corresponding package](https://www.latex-project.org/get/) and use your favourite text editor:

- [macOS: MacTex](http://www.tug.org/mactex/)
- [Windows: MikTeX](https://miktex.org/)
- Linux: Texlive (from packages)

However, to simplify your life, you can make use of [Overleaf.com](https://Overleaf.com) website that is online version, similar to Google Docs but making use of LaTeX.
To start using it, simply go to the website, create a free account, and start using it.

### 2. Create Overleaf paper and fill in the template

For this lab, the same as for the project, you need to use `acmart` template in conference mode with 10pt font.
There are several ways to realize this requirement, the simplest is just to copy a few files from the [unofficial paper template](https://github.com/conference-websites/acmart-sigproc-template).

- Create an empty paper project in your Overleaf account

- On your local machine, download `acm.bst`, `acmart.cls`, and `sample-sigconf.tex` file

- Upload `acm.bst` and `acmart.cls` files as is

- Copy the contents of `sample-sigconf.tex` into `main.tex`.

It may indicate a few errors while creating PDF, but that is expected at this point.

### 3. Create bibliography file

Bibliography file, or `.bib` file, is a database with any potential references you may use when writing a paper (you don't have to use all of them, only those that you used will be taken).

For the purpose of this lab, you will need to create `myrefs.bib` file that includes two entries:
- one with keyword `lamport1994latex` for "LATEX: a document preparation system: user's guide and reference manual" book,
- and another one with keyword `clemm2006network` for book by Alexander Clemm "Network management fundamentals". Cisco Press, 2006.

The entry must be in a special BibTeX format and you can find one easily on [Google Scholar](https://scholar.google.com).
The first one I found for you and you will need to find the other one:

```
@book{lamport1994latex,
  title={LATEX: a document preparation system: user's guide and reference manual},
  author={Lamport, Leslie},
  year={1994},
  publisher={Addison-wesley}
}
```

### 4. Update reference database in `main.tex`

In the end of your `main.tex` you should have

```
\bibliographystyle{acm}
\bibliography{sigproc} 
```

The first line defines which bibliography format to use and the other line sets which database (`.bib`) file to use.
As in the lab we are using different `.bib` file, you need to change it to

```
\bibliographystyle{acm}
\bibliography{myrefs} 
```

### 5. Update authors in `main.tex`

Around line 37, your `main.tex` should have several author blocks:

```
\author{Firstname Lastname}
\authornote{Note}
\orcid{1234-5678-9012}
\affiliation{
  \institution{Affiliation}
  \streetaddress{Address}
  \city{City} 
  \state{State} 
  \postcode{Zipcode}
}
\email{email@domain.com}
```

Keep just a single block and update it with information that relevant to you.  You can remove `authornote`, `orcid`, `streetaddress`, `city`, `state`, and `postcode` lines.

You can also remove lines

```
% The default list of authors is too long for headers}
\renewcommand{\shortauthors}{F. Lastname et al.}
```

and the whole `CCSXML` block and `ccsdesc` lines.

### 6. Update Title and other misc info

The beginning of the template include bunch of miscellaneous information about the paper, including copyright definition, DOI, ISBN, etc.:

```latex
% Copyright
%\setcopyright{none}
%\setcopyright{acmcopyright}
%\setcopyright{acmlicensed}
\setcopyright{rightsretained}
%\setcopyright{usgov}
%\setcopyright{usgovmixed}
%\setcopyright{cagov}
%\setcopyright{cagovmixed}


% DOI
\acmDOI{10.475/123_4}

% ISBN
\acmISBN{123-4567-24-567/08/06}

%Conference
\acmConference[SHORTNAME'17]{ACM Long Conference Name conference}{July 1997}{City, State, Country} 
\acmYear{2017}
\copyrightyear{2017}

\acmPrice{15.00}


\begin{document}
\title{SIG Proceedings Paper in LaTeX Format}
\titlenote{Produces the permission block, and copyright information}
\subtitle{Extended Abstract}
```


You can remove most of it, just keeping the `title` line, which must state "Lab-1: My First LaTeX Document":

```
\begin{document}
\title{Lab-1: My First \LaTeX Document}
```

(Note the use of `\LaTeX` which is a special command to properly format word `LaTeX`)

### 7. Fill abstract

Again, in `main.tex`, you can find the block that defines the abstract for the paper.
Fill it with text describing how you enjoy or hate using LaTeX so far.
Make sure you created two paragraphs (even artificially), just to make sure you know how to separate paragraphs.

Note that to make a separate paragraph, you need to separate them with a blank line.  If you just break the line, LaTeX will ignore that.

Don't copy/paste this, but just as an example:

```
\begin{abstract}
The LaTeX is great.

I hate LaTeX!
\end{abstract}
```

### 8. Create multi-file structure

LaTeX allows you to define the content of the paper in multiple files.
For the purpose of this lab, you will need to create `body.tex` file where you would write the section called "Body" with any description of your favorite fox.

```
\section{Body}

My favorite fox is ...
```

Just creating the file is not enough, it should be linked from the "main" file, which is `main.tex` in the lab.  What you would need is to replace all the content starting from `\keywords{ACM proceedings}` up until `\bibliography` line with just

```
\input{body}
```

Now, the compiled version should have:

- title
- your name
- abstract containing two paragraphs
- default blocks provided by acmart style
- Section 1 Body, with one paragraph about your favorite fox
- References section with no content

### 9. Adding picture of a fox

The first step of adding a picture, is to making one.  For example, google a fox picture and upload it to Overleaf.

After you done that, you can add picture by writing a following block in `body.tex`:

```
\begin{figure}[htbp]
  \centering
  \includegraphics[width=\columnwidth]{fox-picture.jpg}
  \caption{Fox}
  \label{fig:fox}
\end{figure}
```

### 10. Adding more text and reference

Fill some more text in `body.tex`, making use of

- `\subsection{Subsection Name}` to make a subsection called "Subsection Name"
- `\subsubsection{3rd level subsection} to make a third level subsection, and
- `\paragraph{Foobar}` to make a named paragraph.

Anywhere in the text, include the following:

```
\cite{lamport1994latex}
\cite{lamport1994latex, clemm2006network}
```

### 11. Add Conclusions

In `main.tex` just after the `\input{body}` line, add

```
\section{Conclusions}
```

followed by any additional thoughts you had about the lab, problems you encountered, new things you have learned.

### 12. Enjoy your PDF

At this point you're done and can take some time to be proud of your achievements.

### 13. Prepare the submission

You would need to submit to Gradescope the source of the LaTeX.
Do download source from the Overleaf, click "Menu" button in top left corner and select "Source".

## Submission

Go to the Gradescope and submit the downloaded `.zip` with source of your paper.
The Gradescope will automatically unpack and then, using your source code, build the PDF.

Files that you should have inside .zip file:

- `./main.tex`   (the starting file and content of abstract and conclusion)
- `./acm.bst`    (ACM reference format)
- `./acmart.cls` (the document class file)
- `./body.tex`   (content of the body section)
- `./myrefs.bib` (reference database)
- `./fox.jpg` (or any other picture you downloaded)
