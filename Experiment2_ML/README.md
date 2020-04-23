--------------------------------------------------------------------------
 STATEMENT:
 This file is part of <https://github.com/medomics>, a package providing 
 research utility tools for developing precision medicine applications.
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


######### Automatic Omics based Machine Learning (Auto_OML) toolbox ##########

Author   : Taman Upadhaya <tamanupadhaya@gmail.com>
Date: 3.5, 17/12/2019

Contributors: Olivier Morin, Martin Vallières, Jorge Barrios

#################### PREREQUISITES ###################

* Windows or MAC or Linux operating systems
* R version (3.6.1) and above

##################### GENERAL INFORMATION ############

FOLDER:

[1] Algorithms: contains 7 different algorithm (Random Forest, Support Vector machine, CART, LASSO, Univariate Coxph and multivariate Penalized Coxph)
* Parameter tuning is done using gird seach tehnique for each algorithm using choosen cross validation method
* refer inside the algorithm for details for parameter search bound
* For IMBALANCE CLASSIFICATION: SMOTE algorithm is automatically used to balance data in training 
 
 [2] Dataset: conatains folder for training and testing dataset 
* (dataset with name "Training_Dataset.csv" and "Testing_Dataset.csv" must be there for Random Forest, Support Vector machine, CART, LASSO algorithm to execute and "Training_Dataset_COX.csv" and "Testing_Dataset_COX.csv" must be there for Univariate Coxph and "Training_Dataset_multi_COX.csv" and "Testing_Dataset_multi_COX.csv" multivariate Penalized Coxph)
* || Training data should be balanced i.e equal number of patients in both class||
* Always first row should be patients ID and last row should be class.

[3] Results: contains result from the all algorithms inside algorithm named floder
* refer below for more info

[4] Evaluation_Figure: tt takes all the results from Results folder and plots the ROC, Barchart, importance scrore


################### ALGORITHMS ################

Main_Train_Algorithms.R => Training code
Main_Test_Algorithms.R                     => Testing code  
Main_Training_Testing_Class_Probability.R  => Obtaining class and probability of training and testing dataset from final model 

Executing code
Load the script and simply run in Rstudio 
Command line:  
[1] cd to folder .../Auto_OML/Algorithms
[2] Rscript Main_Train_Algorithms.R                    # For training
[3] Rscript Main_Test_Algorithms.R                     # For testing
[4] Rscript Main_Training_Testing_Class_Probability.R  # For class and probability


Results
All the results for all algorithm will be written on folder Results inside used algorithm floder

For e.g if you use Random Forest algorithm the results will be writtern inside Results/Random_Forest/

Results files  
[1] Random_Forest_Training_Results.csv        # Contains development and cross-validation results
[2] Random_Forest_Testing_Results.csv         # Contains testing results
[3] Random_Forest_Train_class_probability.csv # Contains training dataset probability and class
[4] Random_Forest_Test_class_probability.csv  # Contains testing dataset probability and class

NOTE
[1] There are various cross validation method: LOOCV (default), 5/10-fold, 5/10-repated 5/10 cross-validation
[2] RF split and number of TREE (default 500) grid search bound can be change
[3] There are various options that can be modified

################ Evaluation_Figure #############

It takes all the results from Results folder and plots the AUC, Barchart, feature importance scrore

Executing code
Load the script simply run line by line in Rstudio 
command line  
[1] cd to folder .../Auto_OML/Evaluation_Figure/
[2] Rscript Evaluation_Figure.R # Graph will be save in the same folder
[3] Graph (Cross-validation, Testing): ROC and AUC 


############## CONDA INSTRUCTION ###########

1.  conda create -n R_shared_env r-essentials r-base
2.  conda activate R_shared_env
3.  conda install -c r r-caret
4.  conda install -c conda-forge r-readr 
5.  conda install -c r r-doparallel 
6.  conda install -c r r-proc 
7.  conda install -c r r-domc 
8.  conda install -c conda-forge r-dmwr 
9.  conda install -c conda-forge r-gbm 
10. conda install -c r r-e1071
11. conda install -c conda-forge parallel
12. conda install -c conda-forge r-klar 

############## ACKNOWLEDGEMENTS #############

Package used: [1] caret
	      [2] doMC
	      [3] readr
	      [4] pROC
	      [5] SMOTE
	      [6] survival
	      [7] dplyr
	      [8] survminer
              [9] hdnom https://cran.r-project.org/web/packages/hdnom/vignettes/hdnom.html#1_introduction
*The code should automatically install all the required package otherwise do it manually

----------------------------------------------------------------------------------------------------------------------------
