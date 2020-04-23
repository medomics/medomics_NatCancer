#******************************************************************************************************************************************************************************************
#********************************************************************************************* AUTOMATIC MULTI-OMICS BASED MACHINE LEARNING (Auto_OML) ************************************
#******************************************************************************************************************************************************************************************
#@author  Taman Upadhaya <tamanupadhaya@gmail.com>
#@version 3.5, 17/12/2019
#@since   R version (3.6.1).
# -----------------------------------------------------------------------------
# STATEMENT:
#
#  This file is part of <https://github.com/medomics>, a package providing 
#  research utility tools for developing precision medicine applications.
#  --> Copyright (C) 2020  MEDomics consortium
# 
#      This package is free software: you can redistribute it and/or modify
#      it under the terms of the GNU General Public License as published by
#      the Free Software Foundation, either version 3 of the License, or
#      (at your option) any later version.
# 
#      This package is distributed in the hope that it will be useful,
#      but WITHOUT ANY WARRANTY; without even the implied warranty of
#      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#      GNU General Public License for more details.
#  
#      You should have received a copy of the GNU General Public License
#      along with this package.  If not, see <http://www.gnu.org/licenses/>.
# -----------------------------------------------------------------------------


#******************************************************************************************************************************************************************************************
#******************************************************************************************************************************************************************************************
#******************************************************************************************************************************************************************************************
# This is code to replicate the analyses of MEDomics paper 
start.time <- Sys.time()

cat("Executing Algorithm:","\n")
cat("CART","\n")
source("./CART/CART_Training_Testing_Class_Probability.R")

cat("Executing Algorithm:","\n")
cat("Gradient Boosting Machines","\n")
source("./GBM/GBM_Training_Testing_Class_Probability.R")

cat("Executing Algorithm:","\n")
cat("LASSO","\n")
source("./Logistic_regression_(LASSO_L1)/Lasso_Training_Testing_Class_Probability.R")

cat("Executing Algorithm:","\n")
cat("Random Forest","\n")
source("./Random_Forest/RF_Training_Testing_Class_Probability.R")

cat("Executing Algorithm:","\n")
cat("Naive_Bayes","\n")
source("./Naive_Bayes/NB_Training_Testing_Class_Probability.R")

cat("Executing Algorithm:","\n")
cat("Support Vector Machine","\n")
source("./Support_Vector_machine/SVM_Training_Testing_Class_Probability.R")

end.time <- Sys.time()
cat("\n","All ML algorithms execution time: ",end.time - start.time,"\n")

