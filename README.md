# Replication Package SLR Evaluations at ECSA

This is the replication package of the following paper, submitted to ECSA 2021.

> Marco Konersmann, Angelika Kaplan, Thomas Kühn, Robert Heinrich, Anne Koziolek, Ralf Reussner, Jan Jürjens, Mahmood al-Doori, Marco Ehl, Dominik Fuchß, Katharina Großer, Sebastian Hahner, Jan Keim, Matthias Lohr, Timur Sağlam, Sophie Schulz, and Jan-Philipp Töberg: A Systematic Literature Review on the Evaluation of Software Architecture Research

Please find the following content:

* **Folders**
  * data -- CSV files with the data as input to the diagrams
  * figs -- Diagrams created by the ruby scripts (see below)
  * tables -- contains the overview.tex file, which is used as input to the summary.tex
* **Documents and Tables**
  * ECSA-Proceedings.bib -- Contains the BibTeX entries of ECSA papers 2007 to 2020
  * Data Extraction Form.docx -- The data extraction form used for extracting data during the SLR.
  * Normalized Data.csv -- The data collected during the data extraction, normalized.
  * summary.(tex|pdf) -- A summarizing document with all diagrams, a table of all papers with extracted reesarch objects, evaluation methods and properties, references to all papers considered in the SLR (sources, document).
* **Scripts**
  * *\*.awk -- Awk scripts are used to create the corresponding of the \**.csv files in data
  * *.rb -- Ruby scripts to build the respective figures in figs as* .\*.tex files
  * make.sh -- A script to call all other scripts for creating diagrams and the summary.
* **Requirements**
  * A UNIX commandline environment (e.g., bash) with  awk installed
  * Ruby (2.5 or higher)

To create the diagrams, please run the script `make.sh` in a UNIX commandline environment
