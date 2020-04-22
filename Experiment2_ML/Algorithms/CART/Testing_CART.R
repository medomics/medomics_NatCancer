#******************************************************************************************************************************************************************************************
#********************************************************************************************* TESTING CART ALGORITHM ************************************************************
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
set.seed(2019)
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________________
#----------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________________
myFile  <-".././Results/CART/CART_Training_Results.csv"
myData  <- read_csv(myFile)

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
CART_maxdepth     <- myData$CART_train_cost 
featureRankedList <- myData$Ranked_feature_List
Accuracydetails   <- matrix(, nrow = length(featureRankedList), ncol = 14)

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________________

#__________________________________________________________________________________________________________________________________________________________________________________________
#  TESTING WITH PREVIOUSLY BUILD MODEL 
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

for(nfeatures in 1:length(featureRankedList)){
  
    CARTModel <- train(x=TrainSample[, featureRankedList[1:nfeatures],drop = FALSE], y = Class, method = "rpart2", trControl = fitControl,tuneGrid = data.frame(maxdepth=CART_maxdepth[nfeatures]), metric="ROC")  
    cat("############################## Feature Index ###############################","\n")
    cat(featureRankedList[1:nfeatures],"\n")
    cat("############################## Test results ################################","\n")
    predictionsTest_prob <- predict(CARTModel,TestSample[, featureRankedList[1:nfeatures],drop = FALSE],type = "prob")
    predictionsTestAcc   <- predict(CARTModel,TestSample[, featureRankedList[1:nfeatures],drop = FALSE])
    
    Test_roc_obj <- roc(Test_Class,predictionsTest_prob$no, ci=TRUE, of="auc")
    Test_AUC<-(Test_roc_obj$auc)
    Test_AUC_Upper <- Test_roc_obj$ci[3]
    Test_AUC_Lower <- Test_roc_obj$ci[1]
    
    cat("AUC",Test_AUC,"\n")
    Test_Results           <-confusionMatrix(predictionsTestAcc,Test_Class)
    cat("Accuracy",Test_Results$overall[1],"\n")
    cat("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!","\n")
    MCC_Test               <-((Test_Results$table[1]*Test_Results$table[4])-(Test_Results$table[2]*Test_Results$table[3]))/(sqrt(Test_Results$table[1]+Test_Results$table[2])*sqrt(Test_Results$table[3]+Test_Results$table[4])*sqrt(Test_Results$table[2]+Test_Results$table[4])*sqrt(Test_Results$table[1]+Test_Results$table[3]))
    Accuracydetails[nfeatures, 1]  <- Test_Results$overall[1]
    Accuracydetails[nfeatures, 2]  <- Test_Results$overall[3] #AccuracyLower
    Accuracydetails[nfeatures, 3]  <- Test_Results$overall[4] #AccuracyUpper
    Accuracydetails[nfeatures, 4]  <- Test_Results$byClass[1]
    Accuracydetails[nfeatures, 5]  <- Test_Results$byClass[2]
    Accuracydetails[nfeatures, 6]  <- Test_Results$byClass[3]
    Accuracydetails[nfeatures, 7]  <- Test_Results$byClass[4]
    Accuracydetails[nfeatures, 8]  <- Test_AUC
    Accuracydetails[nfeatures, 9]  <- Test_AUC_Upper
    Accuracydetails[nfeatures, 10] <- Test_AUC_Lower
    Accuracydetails[nfeatures, 11] <- MCC_Test
    Accuracydetails[nfeatures, 12] <- Test_Results$byClass[11]
    Accuracydetails[nfeatures, 13] <- Test_Results$byClass[7]  #F1 Score
    Accuracydetails[nfeatures, 14] <- CART_maxdepth[nfeatures]
    
}
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________________
#__________________________________________________________________________________________________________________________________________________________________________________________
#  WRITING TESTING RESULTS
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Result <- data.frame(featureRankedList,Accuracydetails)
write.table(Result, file = ".././Results/CART/CART_Testing_Results.csv", row.names=FALSE, na="", col.names= c("Ranked_feature_List","Test_Accuracy","Test_Accuracy_Upper","Test_Accuracy_Lower",
                                                                                                                 "Test_Sensitivity","Test_Specificity","Test_Positive_Predictive_Value","Test_Negative_Predictive_Value",
                                                                                                                 "Test_AUC","Test_AUC_Upper","Test_AUC_Lower",
                                                                                                                 "Test_MCC","Test_Balanced_Accuracy", "Test_F1_Score","CART_train_cost"), sep=",")
print("Ranked Feature List")
#****************************************************************************************************************************************************************************************** 
#********************************************************************************************* END ****************************************************************************************
#******************************************************************************************************************************************************************************************
 
