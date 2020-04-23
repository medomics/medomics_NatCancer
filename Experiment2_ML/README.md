# Experiment2 - Machine learning

This section is used to reproduce the test experiments of current Figure 5 of the manuscript.

## Description

<em>Automatic Omics based Machine Learning (Auto_OML) toolbox</em>
* Author: Taman Upadhaya <tamanupadhaya@gmail.com>
* Creation data: 2019-12-17

## Prerequisites
* Windows or MAC or Linux operating systems.
* R version (3.6.1) and above.

## Installing

List of commands to install the required packages using conda:

* conda create -n R_shared_env r-essentials r-base
* conda activate R_shared_env
* conda install -c r r-caret
* conda install -c conda-forge r-readr 
* conda install -c r r-doparallel 
* conda install -c r r-proc 
* conda install -c r r-domc 
* conda install -c conda-forge r-dmwr 
* conda install -c conda-forge r-gbm 
* conda install -c r r-e1071
* conda install -c conda-forge parallel
* conda install -c conda-forge r-klar 

## General information

1. 'Algorithms' folder: contains 7 different algorithms (Random Forest, Support Vector machine, CART, LASSO, Univariate Coxph and multivariate Penalized Coxph).
     * Parameter tuning is done using a gird seach technique for each algorithm using chosen cross-validation method.
     * Refer to the specific algorithm for details about parameter search bound.
     * For imbalanced classifications: SMOTE algorithm is automatically used to balance data in training. 
 
2. 'Dataset' folder: contains folder for training and testing datasets. 
     * Dataset with name "Training_Dataset.csv" and "Testing_Dataset.csv" must be present to execute Random Forest, Support Vector machine, CART and LASSO algorithm.
     * "Training_Dataset_COX.csv" and "Testing_Dataset_COX.csv" must be present to execute Univariate Coxph.
     * "Training_Dataset_multi_COX.csv" and "Testing_Dataset_multi_COX.csv" must be present to execute multivariate Penalized Coxph.
     * Training data should be balanced, i.e. having equal number of patients in both classes.
     * The first row in all files must refer to patient IDs and last row to the value of the class.
     * <em>Work in progress</em>: adding sample datasets to this repository.

3. 'Results' folder: contains results for each algorithm. 
     * Please see below for more info.
     * <em>Work in progress</em>: adding sample results to this repository.

4. Evaluation_Figure: reads results in the 'Results' folder and plots the ROC curves, bar charts and importance scores.
     * <em>Work in progress</em>: adding sample results to this repository.

## Algorithms

* Main scripts
     1. Main_Train_Algorithms.R => Training code
     2. Main_Test_Algorithms.R => Testing code
     3. Main_Training_Testing_Class_Probability.R  => Obtaining class and probability of training and testing dataset from final model 

* Executing code
     * Load the script and simply run in Rstudio 
     * Command line:  
          1. cd to folder .../Auto_OML/Algorithms
          2. Rscript Main_Train_Algorithms.R                    # For training
          3. Rscript Main_Test_Algorithms.R                     # For testing
          4. Rscript Main_Training_Testing_Class_Probability.R  # For class and probability


* Results
All the results for all algorithms will be written in the folder 'Results' inside the corresponding algorithm folder. For example, if you use the Random Forest algorithm, the results will be written inside Results/Random_Forest/. The following results files will be created:  
     1. Random_Forest_Training_Results.csv        # Contains development and cross-validation results
     2. Random_Forest_Testing_Results.csv         # Contains testing results
     3. Random_Forest_Train_class_probability.csv # Contains training dataset probability and class
     4. Random_Forest_Test_class_probability.csv  # Contains testing dataset probability and class

* NOTES
     1. There are various cross-validation methods avaialble: LOOCV (default), 5/10-fold, 5/10-repated 5/10 cross-validation.
     2. The grid search bounds for the number of splits and number of decision-trees (default 500) in random forests can be changed.
     3. There are various options that can be modified.

## Evaluation_Figure
For executing the code, load the script and run it in Rstudio. Command line:
1. cd to folder .../Auto_OML/Evaluation_Figure/.
2. Rscript Evaluation_Figure.R # Graph will be saved in the same folder.
3. Graph (Cross-validation, Testing): ROC and AUC.

## Contributors

Thanks to the following people who have contributed to this section:

* [Taman Upadhaya](https://github.com/TmnGitHub)
* [Olivier Morin](https://github.com/OlivierMorinUCSF)
* [Martin Vallières](https://github.com/mvallieres)
* [Jorge Barrios](https://github.com/numeroj)

## Acknowledgments

Packages used:

1. caret
2. doMC
3. readr
4. pROC
5. SMOTE
6. survival
7. dplyr
8. survminer
9. hdnom https://cran.r-project.org/web/packages/hdnom/vignettes/hdnom.html#1_introduction

Note: The code should automatically install all the required packages. Otherwise, please do it manually.

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