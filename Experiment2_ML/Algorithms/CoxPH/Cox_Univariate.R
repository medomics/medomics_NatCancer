#******************************************************************************************************************************************************************************************
#********************************************************************************************* AUTOMATIC MULTI-OMICS BASED MACHINE LEARNING (Auto_OML) ************************************
#******************************************************************************************************************************************************************************************
#@author  Taman Upadhaya <tamanupadhaya@gmail.com>
#@version 3.5, 17/12/2019
#@since   R version (3.6.1).
#******************************************************************************************************************************************************************************************
#******************************************************************************************************************************************************************************************
#******************************************************************************************************************************************************************************************
library(survival)
library(readr)
#___________________________________________________________________________________________________________________________________________________________________________________
#  DATA DECLARATION
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# !!!!!!!!!!!!! Load dataset (Matrix, row=patients col=features) >>> Example: ~/Machine_learning_Radiomics/TRAINING.csv
#!!!!!!!!!!!!!! First column should be Patients ID and last column should always be Status(1 or 0) and second to last shoould be (survivl in days) for datamatrix !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
TrainSample_Temp           <- read_csv(".././Dataset/Training_dataset/Training_Dataset_COX.csv")
dimnames(TrainSample_Temp) <- list(rownames(TrainSample_Temp, do.NULL = FALSE, prefix = "row"), colnames(TrainSample_Temp, do.NULL = FALSE, prefix = "col"))
TrainSample<-(TrainSample_Temp[,-c(1,(ncol(TrainSample_Temp)-1),ncol(TrainSample_Temp))]) # remove first and last column represneting Patients ID and class respectively


Time_sur <- as.numeric(unlist(TrainSample_Temp[,(ncol(TrainSample_Temp)-1)])) # if survival in days remove multiplication by 365
Event_sur <- as.numeric(unlist(TrainSample_Temp[,(ncol(TrainSample_Temp))]))

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________
### cox univariate
uni_cox=function(Data){
  y=coxph(Surv(time, status)~Var,data=Data)
  return(y)
}
table<- matrix(rep(0), nrow = ncol(TrainSample), ncol =7)
colnames(table) <- c("HR","p_value ","concordance","log.test","wald.test","CIlower","CIupper")
rownames(table) <- names(TrainSample)

for(i in 1 : ncol(TrainSample)) {
  Data_temp <- list(Var = unlist(TrainSample[,i]), time = Time_sur, status = Event_sur)
  table[i, 1] <- (summary(uni_cox(Data_temp))[[7]])[2]
  table[i, 2] <- (summary(uni_cox(Data_temp))[[7]])[5]
  table[i, 3] <- round(summary(uni_cox(Data_temp))$concordance[1],3)
  table[i, 4] <- round(summary(uni_cox(Data_temp))$logtest[1],3)
  table[i, 5] <- round(summary(uni_cox(Data_temp))$waldtest[1],3)
  table[i, 6] <- (summary(uni_cox(Data_temp))[[8]])[3]
  table[i, 7] <- (summary(uni_cox(Data_temp))[[8]])[4]
}


#Based on concodance
resultat_unicox_Significant <- table[table[,3] >= 0.55,]
Index_TrainSample          <- as.integer(which(table[,3] >= 0.55))


write.table(resultat_unicox_Significant, file = ".././Results/COX/Results_unicox_Significant.csv", row.names = TRUE, col.names = NA, sep = "\t")
write.table(table, file = ".././Results/COX/Results_unicox_All.csv", row.names = TRUE, col.names = NA, sep = "\t")
