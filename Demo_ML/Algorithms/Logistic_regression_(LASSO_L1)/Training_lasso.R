#******************************************************************************************************************************************************************************************
#********************************************************************************************* TRAINING LASSO ALGORITHM ************************************************************
#******************************************************************************************************************************************************************************************
#@author  Taman Upadhaya <tamanupadhaya@gmail.com>
#@version 3.0, 19/11/2019
#@since   R version (3.4.4).
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


#__________________________________________________________________________________________________________________________________________________________________________________________
#  INSTALLING THE PACKAGES IF NOT INSTALLED
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
packages <- c("caret","doMC","readr","pROC","readxl")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))  
  install.packages("caret", dependencies = c("Depends", "Suggests"))
}
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________________

#__________________________________________________________________________________________________________________________________________________________________________________________
#  LIBRARY DECLARATION
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
library(readr)
library(readxl)
library(caret)
library(doMC)
library(pROC)
registerDoMC(70) #Specify number of core to be used
set.seed(2019)
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________________
start.time <- Sys.time()
#----------------------------------------------------------------------------------------------------------------------------------------------
#____________________________________________________________________________________________________________________________________________________________________________________
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CV         <- 1 # choose option for cross-validation (default bootstrapping)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#____________________________________________________________________________________________________________________________________________________________________________________

#___________________________________________________________________________________________________________________________________________________________________________________
#  DATA DECLARATION
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# !!!!!!!!!!!!! Load dataset (Matrix, row=patients col=features) >>> Example: ~/PhD/Machine_learning_Radiomics/TRAINING.csv
#!!!!!!!!!!!!!! First column should be Patients ID and last column should always be class for datamatrix !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
TrainSample_Temp           <- read_csv(".././Dataset/Training_dataset/Training_Dataset.csv")
dimnames(TrainSample_Temp) <- list(rownames(TrainSample_Temp, do.NULL = FALSE, prefix = "row"), colnames(TrainSample_Temp, do.NULL = FALSE, prefix = "col"))

# !!!!!!! vector denoted by 0 and 1 for Classes >>> Example: c(0,0,0,1,1,1)
Class<-as.factor(unlist(TrainSample_Temp[,ncol(TrainSample_Temp)]))
levels(Class) <- list(no="0", yes="1")
TrainSample<-TrainSample_Temp[,-c(1,ncol(TrainSample_Temp))] # remove first and last column represneting Patients ID and class respectively
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________

#__________________________________________________________________________________________________________________________________________________________________________________
#  PARAMETERS DECLARATION
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Sampling_data = "none"
if(length(which(Class=='no')) !=  length(which(Class=='yes'))){
  print("Data Imbalance: using SMOTE")
  Sampling_data = "smote"
}

#VARIOUS CROSS-VALIDATION
if(CV==1){
  fitControl <-trainControl(method="LOOCV", allowParallel = T, savePredictions = TRUE, classProbs=T, summaryFunction = twoClassSummary, sampling = Sampling_data)
}else if(CV==2){
  fitControl <- trainControl(method="cv", number=10, allowParallel = T, savePredictions = TRUE, classProbs=T, summaryFunction = twoClassSummary, sampling = Sampling_data)
}else if(CV==3){
  fitControl <- trainControl(method="cv", number=5, allowParallel = T, savePredictions = TRUE, classProbs=T, summaryFunction = twoClassSummary, sampling = Sampling_data)
}else if(CV==4){
  fitControl <- trainControl(method="boot",allowParallel = T, savePredictions = TRUE, classProbs=T, summaryFunction = twoClassSummary, sampling = Sampling_data)
}else if(CV==5){
  fitControl <- trainControl(method="repeatedcv", number=5, repeats=5, allowParallel = T, savePredictions = TRUE, classProbs=T, summaryFunction = twoClassSummary, sampling = Sampling_data)
}else{
  fitControl <- trainControl(method="repeatedcv", number=10, repeats=5, allowParallel = T, savePredictions = TRUE, classProbs=T, summaryFunction= twoClassSummary, sampling = Sampling_data)}

# Mtry parameter in grid !!! mtry goes from 1 to sqrt(number of features) for classification
lasso_grid  <-expand.grid(alpha = 1, lambda = seq(0.001,0.1,by = 0.001))
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________

#__________________________________________________________________________________________________________________________________________________________________________________
#  INITIAL MODEL BUILDING 
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
classifierlasso <- train(x=TrainSample, y = Class, trControl = fitControl, method = "glmnet", preProc = c("center", "scale"), tuneGrid = lasso_grid, metric="ROC")
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________

#__________________________________________________________________________________________________________________________________________________________________________________
#  FEATURES IMPORTANCE SCORE CALCULATION 
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Importance score in decreasing order !!! Features with high importance score are ranked first
ImportanceOrder   <- varImp(classifierlasso,scale=F)#order(classifierRandomForest$finalModel$importance[,1],decreasing = TRUE)
featureRankedList <- order(ImportanceOrder$importance$Overall,decreasing = TRUE)
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________

#__________________________________________________________________________________________________________________________________________________________________________________
#  MODEL BUILDING BASED ON RANKED FEATURES 
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#################################### tunning the parameter in parallel ###############################
#number of iterations are equal to number of features
iters           <- ncol(TrainSample)      
Accuracydetails <- matrix(, nrow = ncol(TrainSample), ncol = 28)

for (icount in 2:iters ) {
  TrainCost <- train(x=TrainSample[, featureRankedList[1:icount],drop = FALSE], y = Class, trControl = fitControl, method = "glmnet", preProc = c("center", "scale"), tuneGrid = lasso_grid, metric="ROC")
  nfeatures           <- icount
  cat("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!","\n")
  cat("############################# Feature Index ######################################","\n")
  cat(featureRankedList[1:nfeatures],"\n")
  cat("######################### Development results ####################################","\n")
  fit_prob    <- predict(TrainCost,type = "prob")
  Dev_roc_obj <- roc(Class,fit_prob$no, ci=TRUE, of="auc")
  Dev_AUC<-(Dev_roc_obj$auc)
  Dev_AUC_Upper <- Dev_roc_obj$ci[3]
  Dev_AUC_Lower <- Dev_roc_obj$ci[1]
  cat("AUC",Dev_AUC,"\n")
  Dev_Results                    <-confusionMatrix(predict(TrainCost),Class)
  cat("Accuracy",Dev_Results$overall[1],"\n") #Accuracy
  MCC_Dev                        <-((Dev_Results$table[1]*Dev_Results$table[4])-(Dev_Results$table[2]*Dev_Results$table[3]))/(sqrt(Dev_Results$table[1]+Dev_Results$table[2])*sqrt(Dev_Results$table[3]+Dev_Results$table[4])*sqrt(Dev_Results$table[2]+Dev_Results$table[4])*sqrt(Dev_Results$table[1]+Dev_Results$table[3]))
  Accuracydetails[nfeatures, 1]  <- Dev_Results$overall[1]
  Accuracydetails[nfeatures, 2]  <- Dev_Results$overall[3] #AccuracyLower
  Accuracydetails[nfeatures, 3]  <- Dev_Results$overall[4] #AccuracyUpper
  Accuracydetails[nfeatures, 4]  <- Dev_Results$byClass[1]
  Accuracydetails[nfeatures, 5]  <- Dev_Results$byClass[2]
  Accuracydetails[nfeatures, 6]  <- Dev_Results$byClass[3]
  Accuracydetails[nfeatures, 7]  <- Dev_Results$byClass[4]
  Accuracydetails[nfeatures, 8]  <- Dev_AUC
  Accuracydetails[nfeatures, 9]  <- Dev_AUC_Upper
  Accuracydetails[nfeatures, 10] <- Dev_AUC_Lower
  Accuracydetails[nfeatures, 11] <- MCC_Dev
  Accuracydetails[nfeatures, 12] <- Dev_Results$byClass[11] #Balanced Accuracy
  Accuracydetails[nfeatures, 13] <- Dev_Results$byClass[7]  #F1 Score
  Accuracydetails[nfeatures, 14] <- TrainCost$bestTune$lambda
  Accuracydetails[nfeatures, 15] <- TrainCost$bestTune$alpha
  
  ###### Internal validation results #########################################
  Pred_Index=which(TrainCost$pred$lambda==TrainCost$bestTune$lambda)
  
  CV_roc_obj <- roc(TrainCost$pred$obs[Pred_Index],TrainCost$pred$no[Pred_Index], ci=TRUE, of="auc") #roc(groundtruth,prediction)
  CV_AUC<-(CV_roc_obj$auc)
  CV_AUC_Upper <- CV_roc_obj$ci[3]
  CV_AUC_Lower <- CV_roc_obj$ci[1]
  cat("###################### Internal validation results ###############################","\n")
  cat("AUC:",CV_AUC,"\n")
  CV_Results <-confusionMatrix(TrainCost$pred$pred[Pred_Index],TrainCost$pred$obs[Pred_Index])
  cat("Accuracy",CV_Results$overall[1],"\n") #Accuracy
  cat("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!","\n")
  CV_Accuracy                       <- CV_Results$overall[1]
  CV_AccuracyLower                  <- CV_Results$overall[3] #AccuracyLower
  CV_AccuracyUpper                  <- CV_Results$overall[4] #AccuracyUpper
  CV_Sensitivity                    <- CV_Results$byClass[1]
  CV_Specificity                    <- CV_Results$byClass[2]
  CV_Pos_Pred_Value                 <- CV_Results$byClass[3]
  CV_Neg_Pred_Value                 <- CV_Results$byClass[4]
  CV_Balanced_Accuracy              <- CV_Results$byClass[11]
  MCC_CV                            <-((CV_Results$table[1]*CV_Results$table[4])-(CV_Results$table[2]*CV_Results$table[3]))/(sqrt(CV_Results$table[1]+CV_Results$table[2])*sqrt(CV_Results$table[3]+CV_Results$table[4])*sqrt(CV_Results$table[2]+CV_Results$table[4])*sqrt(CV_Results$table[1]+CV_Results$table[3]))
  F1_Score_CV                       <- CV_Results$byClass[7]#(2*CV_Results$table[1])/((2*CV_Results$table[1])+CV_Results$table[2]+CV_Results$table[3])
  Accuracydetails[nfeatures, 16]    <- CV_Accuracy
  Accuracydetails[nfeatures, 17]    <- CV_AccuracyUpper
  Accuracydetails[nfeatures, 18]    <- CV_AccuracyLower
  Accuracydetails[nfeatures, 19]    <- CV_Sensitivity
  Accuracydetails[nfeatures, 20]    <- CV_Specificity
  Accuracydetails[nfeatures, 21]    <- CV_Pos_Pred_Value
  Accuracydetails[nfeatures, 22]    <- CV_Neg_Pred_Value
  Accuracydetails[nfeatures, 23]    <- CV_AUC
  Accuracydetails[nfeatures, 24]    <- CV_AUC_Upper
  Accuracydetails[nfeatures, 25]    <- CV_AUC_Lower
  Accuracydetails[nfeatures, 26]    <- MCC_CV
  Accuracydetails[nfeatures, 27]    <- CV_Balanced_Accuracy
  Accuracydetails[nfeatures, 28]    <- F1_Score_CV
}
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________

#__________________________________________________________________________________________________________________________________________________________________________________
#  WRITING RESULTS  
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Result <- data.frame(featureRankedList,Accuracydetails)
write.table(Result, file = ".././Results/LASSO/LASSO_Training_Results.csv",row.names=FALSE, na="",col.names=c("Ranked_feature_List","Development_Accuracy","Development_Accuracy_Upper","Development_Accuracy_Lower",
                                                                                                                 "Development_Sensitivity","Development_Specificity","Development_Positive_Predictive_Value", 
                                                                                                                 "Development_Negative_Predictive_Value","Development_AUC","Development_AUC_Upper","Development_AUC_Lower",
                                                                                                                 "Development_MCC","Development_Balanced_Accuracy","Development_F1_Score",
                                                                                                                 "lasso_lamda","lasso_alpha",
                                                                                                                 "CV_Accuracy","CV_Accuracy_Upper","CV_Accuracy_Lower",
                                                                                                                 "CV_Sensitivity","CV_Specificity","CV_Positive_Predictive_Value", "CV_Negative_Predictive_Value",
                                                                                                                 "CV_AUC","CV_AUC_Upper","CV_AUC_Lower","CV_MCC","CV_Balanced_Accuracy","CV_F1_Score"),sep=",")

feat_Imp <- data.frame((colnames(TrainSample)[featureRankedList]), (ImportanceOrder$importance$Overall[featureRankedList]))
write.table(feat_Imp, file = ".././Results/LASSO/LASSO_Ranked_Feature_List.csv",row.names=FALSE, na="",col.names=c("Ranked_feature_List","Score"), sep=",")
end.time <- Sys.time()
Algo_time<-end.time - start.time
print("total execution time:")
print(Algo_time)
#******************************************************************************************************************************************************************************************
#********************************************************************************************* END ****************************************************************************************
#******************************************************************************************************************************************************************************************
