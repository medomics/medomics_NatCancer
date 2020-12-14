# Demo - NLP

This section is used to run and test the code that produce the NLP experiments of current Figure 6 of the manuscript.

## Prerequisites
* MAC or Linux operating systems (tested on CentOS Linux release 7.6.1810).
* Python 3.7.4 and above.

## Installing

List of commands to install the required packages using conda:

* conda install seaborn=0.11.0
* conda install -c anaconda ipykernel
* conda install -c conda-forge lifelines
* conda install -c anaconda scikit-learn
* conda install -c conda-forge matplotlib
* conda install -c anaconda xlsxwriter
* conda install -c conda-forge imbalanced-learn 
* conda install -c anaconda joblib
* conda install -c anaconda scikit-learn 
* conda install -c conda-forge pytest-shutil


## Instructions

This section details the instructions to run the demo experiment, where random text substitutes medical notes of breast cancer patients (processed format: Python pickle objects). 

In the same folder where this file is located:

1. Donwload the demo data file "df_Notes_breast.pkl" from OSF Demo_NLP folder.

2. Check for the existence of the following files:
	* ```survivalnlp.py```
	* ```timeseriesnlp.py```
	* ```RESULTS.ipynb```
    
3. Run the ```timeseriesnlp.py``` script (already configured with the corresponding parameters of options 1 and 2). When the ```timeseriesnlp.py``` script have been completed successfully (the execution time is about 18 hours), check for the existence of the following file:
	* breast30.pickle

4. Run the Jupyter Notebook ```RESULTS.ipynb``` to obtain the graphical results. After running the notebook, EPS, XLSX and PNG  files will be saved in the folders:
    * EPS_stage
    * EPS_experiment
    * XLSX_PNG_experiment
    * XLSX_PNG_stage
    

## Data
In the Demo data generated to run and test the python code of the NLP experiment:
    * The text of each note (deid_notecontent attribute) is a concatenation of random words from the vocabulary
      of the Brown corpus of NLTK [1]. Selections are made according to the relative weights computed from the term frequency in the corpus.
    * None of the attribute values in the Demo data belong to real patients. Each row in the demo data contains a random text (in sustitution of a patient note) and (synthetic) attributes of the "note" and the "patient".
      Number of rows: 451772
      Number of Columns: 9 columns
      # Columns Information:
      --> 'id': Unique identifier for a patient.
      --> 'deid_notecontent': De-identified note.
      --> 'overallsurvival': Survival time from the date of diagnosis in years.
      --> 'vitalstatusbinary': Vital status (0 if alive and 1 if dead).
      --> 'authortype': Author of the note or source.
      --> 'filingdate': Note date.
      --> 'dateofdiagnosis': Date of diagnosis.
      --> 'stage_grade': Stage or grade.
      --> 'AGE': Age at diagnosis.

[1] Bird, Steven, Edward Loper and Ewan Klein (2009), Natural Language Processing with Python. O’Reilly Media Inc.

## Contributors

Thanks to the following people who have contributed to this section:

* [Jorge Barrios](https://github.com/numeroj)
* [Taman Upadhaya](https://github.com/TmnGitHub)
* [Olivier Morin](https://github.com/OlivierMorinUCSF)
* [Martin Vallières](https://github.com/mvallieres)

## STATEMENT

 This file is part of <https://github.com/medomics>, a package providing research utility tools for developing precision medicine applications. 
 
 --> Copyright (C) 2020  MEDomics consortium

     This package is free software: you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
     the Free Software Foundation, either version 3 of the License, or
     (at your option) any later version.

     This package is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     GNU General Public License for more details.
 
     You should have received a copy of the GNU General Public License
     along with this package.  If not, see <http://www.gnu.org/licenses/>.