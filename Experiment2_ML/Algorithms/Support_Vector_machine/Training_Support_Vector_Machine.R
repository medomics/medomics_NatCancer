#******************************************************************************************************************************************************************************************
#********************************************************************************************* TRANING SUPPORT VECTOR MACHINE ALGORITHM ***************************************************
#******************************************************************************************************************************************************************************************
#@author  Taman Upadhaya <tamanupadhaya@gmail.com>
#@version 3.0, 19/11/2019
#@since   R version (3.4.4).
#__________________________________________________________________________________________________________________________________________________________________________________________
#  INSTALLING THE PACKAGES IF NOT INSTALLED
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
packages <- c("caret","doMC","readr","pROC","readxl")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))  
  install.packages("caret", dependencies = c("Depends", "Suggests"))
}
#----------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________________

#__________________________________________________________________________________________________________________________________________________________________________________________
#  LIBRARY DECLARATION
#-----------------------------------------------------------------------------------------------------------------------------------------------
library(readr)
library(readxl)
library(caret)
library(doMC)
library(pROC)
library(e1071)
registerDoMC(70) #Specify number of core to be used
set.seed(2018)
source("./Support_Vector_machine/InternalScalinglinsvmrfeFeatureRanking.R")
start.time <- Sys.time()
#----------------------------------------------------------------------------------------------------------------------------------------------
#____________________________________________________________________________________________________________________________________________________________________________________
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CV         <- 6 # choose option for cross-validation (default LOOCV)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#____________________________________________________________________________________________________________________________________________________________________________________
#  DATA DECLARATION
#-----------------------------------------------------------------------------------------------------------------------------------------------
# !!!!!!!!!!!!! Load dataset (Matrix, row=patients col=features) >>> Example: ~/PhD/Machine_learning_Radiomics/TRAINING.csv
#!!!!!!!!!!!!!! First column should be Patients ID and last column should always be class for datamatrix !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
TrainSample_Temp           <- read_csv(".././Dataset/Training_dataset/Training_Dataset.csv")
dimnames(TrainSample_Temp) <- list(rownames(TrainSample_Temp, do.NULL = FALSE, prefix = "row"), colnames(TrainSample_Temp, do.NULL = FALSE, prefix = "col"))

# !!!!!!! vector denoted by 1 and 0 for Classes >>> Example: c(0,0,0,1,1,1)
Class<-as.factor(unlist(TrainSample_Temp[,ncol(TrainSample_Temp)]))
levels(Class) <- list(no="0", yes="1")
TrainSample<-TrainSample_Temp[,-c(1,ncol(TrainSample_Temp))] # remove first and last column represneting Patients and class respectively
#----------------------------------------------------------------------------------------------------------------------------------------------
#____________________________________________________________________________________________________________________________________________________________________________________

#____________________________________________________________________________________________________________________________________________________________________________________
#  PARAMETERS DECLARATION
#-----------------------------------------------------------------------------------------------------------------------------------------------
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

# Linear SVM C parametrs in a grid
SVMgrid      <- expand.grid(cost=seq(0.001,6,0.1)) # grid search

#----------------------------------------------------------------------------------------------------------------------------------------------
#____________________________________________________________________________________________________________________________________________________________________________________

#____________________________________________________________________________________________________________________________________________________________________________________
#  INITIAL MODEL BUILDING 
#-----------------------------------------------------------------------------------------------------------------------------------------------

#Tunning using Caret package !!!! method svmLinear = Kernallab package and svmLinear2 = e1071 package
SVMfit   <-  train(x=TrainSample, y = Class, method = "svmLinear2",Type="Classification",preProc = c("center", "scale"),trControl = fitControl,tuneGrid = SVMgrid, metric="ROC")
#----------------------------------------------------------------------------------------------------------------------------------------------
#____________________________________________________________________________________________________________________________________________________________________________________

#____________________________________________________________________________________________________________________________________________________________________________________
#  FEATURE RANKING BASED ON THE INITIAL MODEL 
#-----------------------------------------------------------------------------------------------------------------------------------------------
SVMCost           <- SVMfit$bestTune$cost
featureRanked_and_imp_score <- InternalScalinglinsvmrfeFeatureRanking(TrainSample,Class,SVMCost)
featureRankedList <- featureRanked_and_imp_score$featureRankedList
Feature_imp_score<-featureRanked_and_imp_score$Feature_imp_score

print(featureRankedList,) # list of ranked features
#----------------------------------------------------------------------------------------------------------------------------------------------
#____________________________________________________________________________________________________________________________________________________________________________________

#_______________________________________________________________________________________________________________________________________________
#  MODEL BUILDING BASED ON RANKED FEATURES 
#-----------------------------------------------------------------------------------------------------------------------------------------------
# tunning for all the variable together according to added number
##################################### tunning the parameter ###############################
iters           <- ncol(TrainSample)
SVMTrainCost    <- vector('list',length=iters)
Accuracydetails <- matrix(, nrow = ncol(TrainSample), ncol = 27)

for (icount in 1:iters ) {
  nfeatures            <- icount
  SVMModel             <- train(x=TrainSample[, featureRankedList[1:nfeatures],drop = FALSE], y = Class, method = "svmLinear2",Type="Classification",preProc = c("center", "scale"),trControl = fitControl,tuneGrid = SVMgrid, metric="ROC")
  SVMTrainCost[icount] <- SVMModel$bestTune$cost
  
  cat("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!","\n")
  cat("############################# Feature Index ######################################","\n")
  cat(featureRankedList[1:nfeatures],"\n")
  cat("######################### Development results ####################################","\n")
  fit_prob    <- predict(SVMModel,type = "prob")
  Dev_roc_obj <- roc(Class,fit_prob$no, ci=TRUE, of="auc")
  Dev_AUC<-(Dev_roc_obj$auc)
  Dev_AUC_Upper <- Dev_roc_obj$ci[3]
  Dev_AUC_Lower <- Dev_roc_obj$ci[1]
  cat("AUC",Dev_AUC,"\n")
  Dev_Results                    <-confusionMatrix(predict(SVMModel),Class)
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
  Accuracydetails[nfeatures, 14] <- SVMTrainCost[[icount]]

  ################## Internal validation results #########################################
  Pred_Index=which(SVMModel$pred$cost==SVMModel$bestTune$cost)
  
  CV_roc_obj <- roc(SVMModel$pred$obs[Pred_Index],SVMModel$pred$no[Pred_Index], ci=TRUE, of="auc") #roc(groundtruth,prediction)
  CV_AUC<-(CV_roc_obj$auc)
  CV_AUC_Upper <- CV_roc_obj$ci[3]
  CV_AUC_Lower <- CV_roc_obj$ci[1]
  cat("###################### Internal validation results ###############################","\n")
  cat("AUC:",CV_AUC,"\n")
  CV_Results <-confusionMatrix(SVMModel$pred$pred[Pred_Index],SVMModel$pred$obs[Pred_Index])
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
  Accuracydetails[nfeatures, 15]    <- CV_Accuracy
  Accuracydetails[nfeatures, 16]    <- CV_AccuracyUpper
  Accuracydetails[nfeatures, 17]    <- CV_AccuracyLower
  Accuracydetails[nfeatures, 18]    <- CV_Sensitivity
  Accuracydetails[nfeatures, 19]    <- CV_Specificity
  Accuracydetails[nfeatures, 20]    <- CV_Pos_Pred_Value
  Accuracydetails[nfeatures, 21]    <- CV_Neg_Pred_Value
  Accuracydetails[nfeatures, 22]    <- CV_AUC
  Accuracydetails[nfeatures, 23]    <- CV_AUC_Upper
  Accuracydetails[nfeatures, 24]    <- CV_AUC_Lower
  Accuracydetails[nfeatures, 25]    <- MCC_CV
  Accuracydetails[nfeatures, 26]    <- CV_Balanced_Accuracy
  Accuracydetails[nfeatures, 27]    <- F1_Score_CV
}
#----------------------------------------------------------------------------------------------------------------------------------------------
#____________________________________________________________________________________________________________________________________________________________________________________      

#____________________________________________________________________________________________________________________________________________________________________________________
#  WRITING TRANING RESULTS
#-----------------------------------------------------------------------------------------------------------------------------------------------
Result <- data.frame(featureRankedList,Accuracydetails)
write.table(Result, file = ".././Results/Support_Vector_Machine/SVM_Training_Results.csv",row.names=FALSE, na="",col.names=c("Ranked_feature_List","Development_Accuracy","Development_Accuracy_Upper","Development_Accuracy_Lower",
                                                                                                                                "Development_Sensitivity","Development_Specificity","Development_Positive_Predictive_Value", 
                                                                                                                                "Development_Negative_Predictive_Value","Development_AUC","Development_AUC_Upper","Development_AUC_Lower",
                                                                                                                                "Development_MCC","Development_Balanced_Accuracy","Development_F1_Score",
                                                                                                                                "SVM_train_cost",
                                                                                                                                "CV_Accuracy","CV_Accuracy_Upper","CV_Accuracy_Lower",
                                                                                                                                "CV_Sensitivity","CV_Specificity","CV_Positive_Predictive_Value", "CV_Negative_Predictive_Value",
                                                                                                                                "CV_AUC","CV_AUC_Upper","CV_AUC_Lower","CV_MCC","CV_Balanced_Accuracy","CV_F1_Score"), sep=",")

feat_Imp <- data.frame(colnames(TrainSample)[featureRankedList], Feature_imp_score)
write.table(feat_Imp, file = ".././Results/Support_Vector_Machine/SVM_Ranked_Feature_List.csv",row.names=FALSE, na="",col.names=c("Ranked_feature_List","Score"), sep=",")
#----------------------------------------------------------------------------------------------------------------------------------------------
#____________________________________________________________________________________________________________________________________________________________________________________ 
end.time <- Sys.time()
Algo_time<-end.time - start.time
print("total execution time:")
print(Algo_time)      
#******************************************************************************************************************************************************************************************
#********************************************************************************************* END ****************************************************************************************
#******************************************************************************************************************************************************************************************
