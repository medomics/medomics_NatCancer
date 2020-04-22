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
source("./CART/Training_CART.R")

cat("Executing Algorithm:","\n")
cat("Gradient Boosting Machines","\n")
source("./GBM/Training_GBM.R")

cat("Executing Algorithm:","\n")
cat("LASSO","\n")
source("./Logistic_regression_(LASSO_L1)/Training_lasso.R")

cat("Executing Algorithm:","\n")
cat("Random Forest","\n")
source("./Random_Forest/Training_Random_Forest.R")

cat("Executing Algorithm:","\n")
cat("Support Vector Machine","\n")
source("./Support_Vector_machine/Training_Support_Vector_Machine.R")

cat("Executing Algorithm:","\n")
cat("Univariate Coxph","\n")
source("./CoxPH/Cox_Univariate.R")

cat("Executing Algorithm:","\n")
cat("Multivariate Penalized Coxph","\n")
source("./CoxPH/pCox.R")

end.time <- Sys.time()
cat("\n","All ML algorithms execution time: ",end.time - start.time,"\n")

