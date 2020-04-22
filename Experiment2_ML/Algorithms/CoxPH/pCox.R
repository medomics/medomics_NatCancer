#******************************************************************************************************************************************************************************************
#********************************************************************************************* TRAINING GBM ALGORITHM ************************************************************
#******************************************************************************************************************************************************************************************
#@author  Taman Upadhaya <tamanupadhaya@gmail.com>
#@version 3.0, 19/11/2019
#@since   R version (3.4.4).
#__________________________________________________________________________________________________________________________________________________________________________________________
#  INSTALLING THE PACKAGES IF NOT INSTALLED
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#$$$$$$$$$$$$$$$$$%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^%%%%%%%%%%%%%%%%%%%%%%$$$$$$$$$$$$$$$$$$$$$$$
######## NOMOGRAM REGERENCE: https://cran.r-project.org/web/packages/hdnom/vignettes/hdnom.html#1_introduction
#$$$$$$$$$$$$$$$$$%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^%%%%%%%%%%%%%%%%%%%%%%$$$$$$$$$$$$$$$$$$$$$$$
#__________________________________________________________________________________________________________________________________________

packages <- c("hdnom","doParallel","readr","pROC","readxl")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages()))) 
}
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________________

#__________________________________________________________________________________________________________________________________________________________________________________________
#  LIBRARY DECLARATION
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
library(readr)
library(readxl)
library(pROC)
library(gbm)
library(doMC)
library("hdnom")
registerDoMC(70) #Specify number of core to be used
suppressMessages(library("doParallel"))
registerDoParallel(detectCores())
set.seed(2019)
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________________
start.time <- Sys.time()
#----------------------------------------------------------------------------------------------------------------------------------------------
#___________________________________________________________________________________________________________________________________________________________________________________
#  DATA DECLARATION
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#################### Training Dataset ######################################
# !!!!!!!!!!!!! Load dataset (Matrix, row=patients col=features) >>> Example: ~/Machine_learning_Radiomics/TRAINING.csv
#!!!!!!!!!!!!!! First column should be Patients ID and last column should always be Status(1 or 0) and second to last shoould be (survivl in days) for datamatrix !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
TrainSample_Temp           <- read_csv(".././Dataset/Training_dataset/Training_Dataset_multi_COX.csv")

dimnames(TrainSample_Temp) <- list(rownames(TrainSample_Temp, do.NULL = FALSE, prefix = "row"), colnames(TrainSample_Temp, do.NULL = FALSE, prefix = "col"))
names(TrainSample_Temp) <- gsub(" ", "_", names(TrainSample_Temp))

# remove first and last column represneting Patients ID and last column and second last column for survival time and status 
TrainSample <- as.matrix(TrainSample_Temp[,-c(1,(ncol(TrainSample_Temp)-1),ncol(TrainSample_Temp))]) 
Time_sur <- as.numeric(unlist(TrainSample_Temp[,(ncol(TrainSample_Temp)-1)]))*365 # if survival in days remove multiplication by 365
Event_sur <- as.numeric(unlist(TrainSample_Temp[,(ncol(TrainSample_Temp))]))

Surv_obj <- survival::Surv(Time_sur, Event_sur)

Survival_pred_time <-  2 #Breast 5 #Lungs 2
Survival_time_factor <- 365 # if unit is on years 

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
############################# Testing Dataet ######################################
# !!!!!!!!!!!!! Load dataset (Matrix, row=patients col=features) >>> Example: /Dataset/Machine_learning_Radiomics/TRAINING.csv
#!!!!!!!!!!!!!! First column should be Patients ID and last column should always be Status(1 or 0) and second to last shoould be (survivl in days) for datamatrix !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TestSample_Temp           <- read_csv(".././Dataset/Testing_dataset/Testing_Dataset_multi_COX.csv")

dimnames(TestSample_Temp) <- list(rownames(TestSample_Temp, do.NULL = FALSE, prefix = "row"), colnames(TestSample_Temp, do.NULL = FALSE, prefix = "col"))
names(TestSample_Temp) <- gsub(" ", "_", names(TestSample_Temp))

TestSample_Temp <- TestSample_Temp[ which( TestSample_Temp$OVERALL_SURVIVAL < Survival_pred_time | TestSample_Temp$VITAL_STATUS == 0) , ]

# remove first and last column represneting Patients ID and last column and second last column for survival time and status
TestSample <- as.matrix(TestSample_Temp[,-c(1,(ncol(TestSample_Temp)-1),ncol(TestSample_Temp))])

Test_Time_sur <- as.numeric(unlist(TestSample_Temp[,(ncol(TestSample_Temp)-1)]))*365 # if survival in days remove multiplication by 365
Test_Event_sur <- as.numeric(unlist(TestSample_Temp[,(ncol(TestSample_Temp))]))

Test_Surv_obj <- survival::Surv(Test_Time_sur, Test_Event_sur)

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________


#__________________________________________________________________________________________________________________________________________________________________________________
#TrainSample<-TrainSample[-c(468,1019,1105),]
#Surv_obj<-Surv_obj[-c(468,1019,1105)]
#Time_sur <- Time_sur[-c(468,1019,1105)]
#Event_sur <- Event_sur[-c(468,1019,1105)]
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________

#__________________________________________________________________________________________________________________________________________________________________________________
#  INITIAL MODEL BUILDING 
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#penalized Cox model by adaptive elastic-net regularization
Cox_fit <- fit_aenet(TrainSample, Surv_obj, nfolds = 10, rule = "lambda.1se", seed = c(5, 7), parallel = TRUE)
cat(Cox_fit$alpha)

#Initial parameter from fit to do cross validation
model <- Cox_fit$model
alpha <- Cox_fit$alpha
lambda <- Cox_fit$lambda
adapen <- Cox_fit$pen_factor
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________

#__________________________________________________________________________________________________________________________________________________________________________________
#  FEATURES IMPORTANCE SCORE CALCULATION 
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Nomogram for survival 
nom <- as_nomogram(
  Cox_fit, TrainSample, Time_sur, Event_sur,
  pred.at = Survival_time_factor * Survival_pred_time,
  funlabel = paste(toString(Survival_pred_time),"-Year Overall Survival Probability",sep="")
)

plot(nom)

#Cross validation for predicting survival at time
# Model validation by repeated cross-validation with time-dependent AUC
val.repcv <- validate(
  TrainSample, Time_sur, Event_sur,
  model.type = "aenet",
  alpha = alpha, lambda = lambda, pen.factor = adapen,
  method = "repeated.cv", nfolds = 10, rep.times = 5,
  tauc.type = "UNO", tauc.time = Survival_pred_time * Survival_time_factor,
  seed = 1010, trace = TRUE
)

print(val.repcv)
summary(val.repcv)
capture.output(summary(val.repcv), file = ".././Results/COX/pCOX_cross-validation_results.txt")

# #External Validation
val_ext <- validate_external(
   Cox_fit, TrainSample, Time_sur, Event_sur,
   TestSample, Test_Time_sur, Test_Event_sur,
   tauc.type = "UNO",
   tauc.time = Survival_pred_time * Survival_time_factor
 )
print(val_ext)
summary(val_ext)
capture.output(summary(val_ext), file = ".././Results/COX/pCOX_external-validation_results.txt")

end.time <- Sys.time()
cat("\n","Algorithms execution time: ",end.time - start.time,"\n")
# #******************************************************************************************************************************************************************************************
# #********************************************************************************************* END ****************************************************************************************
# #******************************************************************************************************************************************************************************************