# Experiment3_NLP

This section is used to reproduce the test experiments of current Figure 6 of the manuscript.

## Prerequisites
* MAC or Linux operating systems (tested on CentOS Linux release 7.6.1810).
* Python 3.7.4 and above.


## Instructions

This section details the instructions to run the full set of experiments using the text data of UCSF (processed format: Python pickle objects). Due to patient confidentiality issues, these files cannot be shared at the moment. We are currently working on producing a fake sample of text data compatible with the framewework described here. 

1. In the same folder where this file is located, check for the existence of the following files:
	* df_Notes_breast.pkl
	* df_Notes_glioma.pkl
	* df_Notes_lung.pkl
	* df_Notes_prostate.pkl
	* ```survivalnlp.py```
	* ```timeseriesnlp.py```
	* ```RESULTS.ipynb```
	
2. For each type of cancer 'breast', 'prostate', 'lung', 'glioma'; properly configure the ```timeseriesnlp.py``` script (changing the corresponding parameters of options 1 and 2) and run it independently for each configuration (a total of three for each type of cancer). Configuration instructions are provided in the script. When the 12 different configurations of the ```timeseriesnlp.py``` script have been completed successfully, check for the existence of the following files in the same folder where this file is located:
	* breast20.pickle  
	* breast30.pickle
	* breast60.pickle
	* prostate20.pickle
	* prostate30.pickle
	* prostate60.pickle
	* lung20.pickle
	* lung30.pickle
	* lung60.pickle
	* glioma20.pickle
	* glioma30.pickle
	* glioma60.pickle

3. Run the Jupyter Notebook ```RESULTS.ipynb``` to obtain the graphical results. After running the notebook, EPS files will be saved in the folder:
	* EPS_age
    * EPS_stage
    * EPS_experiment

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