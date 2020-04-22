#******************************************************************************************************************************************************************************************
#********************************************************************************************* AUTOMATIC MULTI-OMICS BASED MACHINE LEARNING (Auto_OML) ************************************
#******************************************************************************************************************************************************************************************
#@author  Taman Upadhaya <tamanupadhaya@gmail.com>
#@version 3.5, 17/12/2019
#@since   R version (3.6.1).
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

