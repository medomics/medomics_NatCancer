#******************************************************************************************************************************************************************************************
#********************************************************************************************* TESTING RANDOM FOREST ALGORITHM ************************************************************
#******************************************************************************************************************************************************************************************
#@author  Taman Upadhaya <tamanupadhaya@gmail.com>
#@version 3.0, 19/11/2019
#@since   R version (3.4.4).
#__________________________________________________________________________________________________________________________________________________________________________________________
#  INSTALL THE PACKAGES IF NOT INSTALLED
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
packages <- c("caret","doMC","readr","pROC")
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
registerDoMC(10) #Specify number of core to be used
set.seed(2018)
#--------------
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________________
#rm(list=ls(all=TRUE)) # clear all variable

myFile  <-".././Results/Random_Forest/Random_Forest_Training_Results.csv"
myData  <- read_csv(myFile)
AUC_threshold = TRUE

#__________________________________________________________________________________________________________________________________________________________________________________________
#  DATA DECLARATION
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  Train Sample
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# !!!!!!!!!!!!! Load dataset (Matrix, row=patients col=features) >>> Example: ~/PhD/Machine_learning_Radiomics/TRAINING.csv
#!!!!!!!!!!!!!! First column should be Patients ID and last column should always be class for datamatrix !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
TrainSample_Temp           <- read_csv(".././Dataset/Training_dataset/Training_Dataset.csv")
dimnames(TrainSample_Temp) <- list(rownames(TrainSample_Temp, do.NULL = FALSE, prefix = "row"), colnames(TrainSample_Temp, do.NULL = FALSE, prefix = "col"))

# !!!!!!! vector denoted by 0 and 1 for Classes >>> Example: c(0,0,0,1,1,1)
Class         <-as.factor(unlist(TrainSample_Temp[,ncol(TrainSample_Temp)]))
levels(Class) <- list(no="0", yes="1")
TrainSample   <-TrainSample_Temp[,-c(1,ncol(TrainSample_Temp))] # remove first and last column represneting Patients and class respectively
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  Test Sample
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# !!!!!!!!!!!!! Load dataset (Matrix, row=patients col=features) >>> Example: ~/PhD/Machine_learning_Radiomics/TRAINING.csv
#!!!!!!!!!!!!!! First column should be Patients ID and last column should always be class for datamatrix !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
TestSample_Temp           <- read_csv(".././Dataset/Testing_dataset/Testing_Dataset.csv")
dimnames(TestSample_Temp) <- list(rownames(TestSample_Temp, do.NULL = FALSE, prefix = "row"), colnames(TestSample_Temp, do.NULL = FALSE, prefix = "col"))

# !!!!!!! vector denoted by 0 and 1 for Classes >>> Example: c(0,0,0,1,1,1)
Test_Class                <- as.factor(unlist(TestSample_Temp[,ncol(TestSample_Temp)]))
levels(Test_Class)        <- list(no="0", yes="1")
TestSample                <- TestSample_Temp[,-c(1,ncol(TestSample_Temp))] # remove first and last column represneting Patients and class respectively

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________________

#__________________________________________________________________________________________________________________________________________________________________________________________
#  PARAMETERS DECLARATION
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Sampling_data = "none"
if(length(which(Class=='no')) !=  length(which(Class=='yes'))){
  print("Data Imbalance: using SMOTE")
  Sampling_data = "smote"
}

fitControl        <- trainControl(method = "none", classProbs = TRUE, sampling = Sampling_data)

# Previously tune parameters
RFmtry            <- myData$RF_train_cost
featureRankedList <- myData$Ranked_feature_List
TREE              <- myData$TREE

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# state the final number of feature based on ranking (default combination of feature that gives max CV AUC)
if (AUC_threshold == TRUE)
{
  max_feat <- myData$CV_AUC[1]
  for(Index_nfeatures in 1:length(myData$CV_AUC)){
    max_feat_temp = myData$CV_AUC[Index_nfeatures]
    if((max_feat_temp-max_feat)>0.0045){
      max_feat = max_feat_temp
      nfeatures <- Index_nfeatures
    }
  }
}else{
  nfeatures         <- which.max(myData$CV_AUC)
}
cat(nfeatures,'\n')
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________________

#__________________________________________________________________________________________________________________________________________________________________________________________
#  TESTING WITH PREVIOUSLY BUILD MODEL 
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RFModel                  <- train(x=TrainSample[, featureRankedList[1:nfeatures],drop = FALSE], y=(Class), method = "rf",Type="Classification",trControl = fitControl,tuneGrid =data.frame(mtry=RFmtry[nfeatures]),ntree=TREE[nfeatures], metric="ROC") # Caret

#Write probability for train sample without smote
predictions_prob_Train   <- predict(RFModel,TrainSample[, featureRankedList[1:nfeatures],drop = FALSE],type = "prob")
predictions_class_Train  <- predict(RFModel,TrainSample[, featureRankedList[1:nfeatures],drop = FALSE])

# Write probability for test sample
predictions_Test_prob     <- predict(RFModel,TestSample[, featureRankedList[1:nfeatures],drop = FALSE],type = "prob")
predictions_Test_class    <- predict(RFModel,TestSample[, featureRankedList[1:nfeatures],drop = FALSE])
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________________
#__________________________________________________________________________________________________________________________________________________________________________________________
#  WRITING RESULTS
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
write.table((cbind(predictions_prob_Train$no,predictions_prob_Train$yes,predictions_class_Train, nfeatures)), file = ".././Results/Random_Forest/Random_Forest_Train_class_probability.csv", row.names = FALSE, na="",col.names=c("Probability_Class_1","Probability_Class_2","Class", "Max_features"),sep = ",")
write.table((cbind(predictions_Test_prob$no,predictions_Test_prob$yes,predictions_Test_class, nfeatures)), file = ".././Results/Random_Forest/Random_Forest_Test_class_probability.csv", row.names = FALSE, na="",col.names=c("Probability_Class_1","Probability_Class_2","Class", "Max_features"),sep = ",")  

#****************************************************************************************************************************************************************************************** 
#********************************************************************************************* END ****************************************************************************************
#******************************************************************************************************************************************************************************************

