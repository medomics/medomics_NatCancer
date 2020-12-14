# Figure 6

This section is used to reproduce the NLP experiments of current Figure 6 of the manuscript.

Due to patient confidentiality issues, original files cannot be shared at the moment.  However, we have produced a compatible Demo example, to run and test the python code of the NLP framework that produces the results shown in Figure 6 (see the Demo_NLP folder of this repository).

In this section, the graphical results with the real data are printed on Jupyter Notebook ```RESULTS.ipynb```.


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

This section details the instructions to run the full set of experiments using medical notes of cancer patients (processed format: Python pickle objects). 

In the same folder where this file is located:
1. Donwload from our [OSF project](https://osf.io/ytge5/) the following files (currently not available due to patient confidentiality issues):
	* df_Notes_breast.pkl
	* df_Notes_lung.pkl
	* df_Notes_glioma.pkl
	* df_Notes_prostate.pkl
2. Check for the existence of the following files:
	* ```survivalnlp.py```
	* ```timeseriesnlp.py```
	* ```RESULTS.ipynb```
3. For each type of cancer 'breast', 'prostate', 'lung', 'glioma'; properly configure(*) the ```timeseriesnlp.py``` script and run it independently for each configuration. Configuration instructions are provided in the script. When the different configurations of the ```timeseriesnlp.py``` script have been completed successfully, check for the existence of the following files:
	* breast30.pickle
	* lung30.pickle
	* glioma30.pickle
	* prostate60.pickle

(*) Change the corresponding parameters of option 1 (0 --> breast, 1 --> prostate, 2 --> lung, 3 --> glioma) and option 2 (1 --> 30 days for breast, lung, glioma; 2 --> 60 days for prostate).

4. Run the Jupyter Notebook ```RESULTS.ipynb``` to obtain the graphical results. After running the notebook, EPS, XLSX and PNG  files will be saved in the folders:
    * EPS_stage
    * EPS_experiment
    * XLSX_PNG_experiment
    * XLSX_PNG_stage
    
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
