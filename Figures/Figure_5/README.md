# Figure 5 and Supplemental Figure 5

This section is used to reproduce the graphics inserted in Figure 3 of the manuscript.

## Prerequisites
* MAC or Linux operating systems (tested on CentOS Linux release 7.6.1810).
* R version (3.6.1) and above.

## Installing

List of commands to install the required packages using conda manually:

* conda create -n R_shared_env r-essentials r-base
* conda activate R_shared_env
* conda install -c russh r-survminer
* conda install -c conda-forge r-readr
* conda install -c r r-survival
* conda install -c r r-proc


## Instructions

1. Create a folder with the name 'Data' in the same directory where this file is located.
2. Download all files from the "Figures/Figure_5" folder of our [OSF project](https://osf.io/ytge5/). Place them in the 'Data' folder.The collection of CSV files contains the data to obtain the graphical results with the R ```Figure_5_plot.R```.
3. Run the R ```Figure_5_plot.R``` to obtain the graphical results.

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
