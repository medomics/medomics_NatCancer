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


library(readr)
library(readxl)
library(caret)
library(doMC)
library(pROC)
registerDoMC(10) #Specify number of core to be used
set.seed(2019)

Groundtruth_Results_Test = read_csv('/home/picare/Programs/Auto_OML/Dataset/Testing_dataset/Testing_Dataset.csv')
Groundtruth_Results_Train = read_csv('/home/picare/Programs/Auto_OML/Dataset/Training_dataset/Training_Dataset.csv')

Classification_Results_SVM = read_csv('../Results/Support_Vector_Machine/SVM_Test_class_probability.csv') 
Classification_Results_SVM_Training = read_csv('../Results/Support_Vector_Machine/SVM_Training_Results.csv')
Classification_Results_SVM_Testing = read_csv('../Results/Support_Vector_Machine/SVM_Testing_Results.csv')
Classification_Results_SVM_Ranked_features = read_csv('../Results/Support_Vector_Machine/SVM_Ranked_Feature_List.csv')

Classification_Results_LASSO = read_csv('../Results/LASSO/LASSO_Test_class_probability.csv') 
Classification_Results_LASSO_Training = read_csv('../Results/LASSO/LASSO_Training_Results.csv') 
Classification_Results_LASSO_Testing = read_csv('../Results/LASSO/lasso_Testing_Results.csv')  
Classification_Results_LASSO_Ranked_features = read_csv('../Results/LASSO/LASSO_Ranked_Feature_List.csv')

Classification_Results_RF = read_csv('../Results/Random_Forest/Random_Forest_Test_class_probability.csv')  
Classification_Results_RF_Training = read_csv('../Results/Random_Forest/Random_Forest_Training_Results.csv')
Classification_Results_RF_Testing = read_csv('../Results/Random_Forest/Random_Forest_Testing_Results.csv') 
Classification_Results_RF_Ranked_features = read_csv('../Results/Random_Forest/Random_Forest_Ranked_Feature_List.csv')

Classification_Results_CART = read_csv('../Results/CART/CART_Test_class_probability.csv')
Classification_Results_CART_Training = read_csv('../Results/CART/CART_Training_Results.csv')
Classification_Results_CART_Testing = read_csv('../Results/CART/CART_Testing_Results.csv')
Classification_Results_CART_Ranked_features = read_csv('../Results/CART/CART_Ranked_Feature_List.csv')

Classification_Results_GBM = read_csv('../Results/GBM/GBM_Test_class_probability.csv')
Classification_Results_GBM_Training = read_csv('../Results/GBM/GBM_Training_Results.csv')
Classification_Results_GBM_Testing = read_csv('../Results/GBM/GBM_Testing_Results.csv')
Classification_Results_GBM_Ranked_features = read_csv('../Results/GBM/GBM_Ranked_Feature_List.csv')

Validation <- "5-Repeat 10-Fold Cross-Validation"

#------------------------------------------ ROC plot ---------------------------------------------------------
###############################################################################################################
#WHen saving image use width=650 and height=560
pROC_obj_SVM <- roc(Groundtruth_Results_Test$CLASS,Classification_Results_SVM$Probability_Class_1,
                     # arguments for ci
                     ci=TRUE, ci.alpha=0.95)
plot(pROC_obj_SVM, legacy.axes = TRUE, main = "Independent Testing ROC", print.auc=TRUE, col='darkgreen', print.auc.x = 0.35, print.auc.y = 0.0)

pROC_obj_LASSO <- roc(Groundtruth_Results_Test$CLASS,Classification_Results_LASSO$Probability_Class_1,
                      # arguments for ci
                      ci=TRUE, ci.alpha=0.95)

plot(pROC_obj_LASSO, add=TRUE, col='blue',print.auc=TRUE, print.auc.x = 0.35, print.auc.y = 0.05)

pROC_obj_RF <- roc(Groundtruth_Results_Test$CLASS,Classification_Results_RF$Probability_Class_1,
                   # arguments for ci
                   ci=TRUE, ci.alpha=0.95)
plot(pROC_obj_RF, add=TRUE, col='purple',print.auc=TRUE, print.auc.x = 0.35, print.auc.y = 0.1)


pROC_obj_CART <- roc(Groundtruth_Results_Test$CLASS,Classification_Results_CART$Probability_Class_1,
                     # arguments for ci
                     ci=TRUE, ci.alpha=0.95)
plot(pROC_obj_CART, add=TRUE, col='black',print.auc=TRUE, print.auc.x = 0.35, print.auc.y = 0.15)


pROC_obj_GBM <- roc(Groundtruth_Results_Test$CLASS,Classification_Results_GBM$Probability_Class_1,
                     # arguments for ci
                     ci=TRUE, ci.alpha=0.95)
plot(pROC_obj_GBM, add=TRUE, col='brown',print.auc=TRUE, print.auc.x = 0.35, print.auc.y = 0.2)


# Add a legend
legend(x=0.65, y=0.395,bg="transparent", legend=c( "GBM", "CART","LASSO", "RF","SVM"), 
       col=c('red', 'black', 'purple', 'blue','darkgreen'), lwd=1, box.lty=0, cex=0.93,
       text.col = c('lightblue','red', 'darkorange', 'brown', 'black', 'purple', 'blue','darkgreen'))

#dev.off()

#------------------------------------------ Training, Vidation and Independent Testing Bar plot ---------------------------------------------------------
##########################################################################################################################################################################################
#$$$$$$$$$$$$$ to save use Width=960 and height = 760 $$$$$$$$$$$$$$$$$$$$$

SVM_Index    <- Classification_Results_SVM$Max_features[1]
CART_Index   <- Classification_Results_CART$Max_features[1]
LASSO_Index  <- Classification_Results_LASSO$Max_features[1]
RF_Index     <- Classification_Results_RF$Max_features[1]
GBM_Index    <- Classification_Results_GBM$Max_features[1]


# AUC Bar Plot  
Eval_table <- cbind(c(Classification_Results_SVM_Training$CV_AUC[SVM_Index],Classification_Results_SVM_Testing$Test_AUC[SVM_Index]),
                    c(Classification_Results_CART_Training$CV_AUC[CART_Index], Classification_Results_CART_Testing$Test_AUC[CART_Index]),
                    c(Classification_Results_LASSO_Training$CV_AUC[LASSO_Index], Classification_Results_LASSO_Testing$Test_AUC[LASSO_Index]),
                    c(Classification_Results_RF_Training$CV_AUC[RF_Index], Classification_Results_RF_Testing$Test_AUC[RF_Index]),
                    c(Classification_Results_GBM_Training$CV_AUC[GBM_Index], Classification_Results_GBM_Testing$Test_AUC[GBM_Index]))
      
rownames(Eval_table) <- c(Validation,"Independent Testing")
colnames(Eval_table) <- c("SVM","CART","LASSO","RF","GBM")

par(mar=c(4,4,8,4))
bp<- barplot(Eval_table,
             #main = "Survival of Each Class",
             xlab = "Machine Learning Classifier",
             ylab = "Area Under Curve (AUC)",
             ylim = c(0,1.05),
             col = c("gray","black"), beside = TRUE,
)
text(x = bp, y = round(as.vector(Eval_table),2), label = round(as.vector(Eval_table),2), pos = 3, cex = 0.6, col = "red")

legend("topright",
       c(Validation,"Independent Testing"),
       fill = c("gray","black"),
       box.lty=0, bg="transparent",  inset = c(-0.19,-0.2), xpd = TRUE
)

#--------------------------------------------------- Feature Importance bar plot ---------------------------------------------------------
########################################################################################################################################################################################
#CART Feature Importance
Sort_index =  order(Classification_Results_CART_Ranked_features$Score[1:CART_Index],decreasing = FALSE)
Eval_table <-  matrix(Classification_Results_CART_Ranked_features$Score[Sort_index], nrow=1)
#rownames(Eval_table) <- c("Training",Validation,"Independent Testing")
colnames(Eval_table) <- Classification_Results_CART_Ranked_features$Ranked_feature_List[Sort_index]

# Increase margin size
par(mar=c(4,15,4,4))
barplot(Eval_table,
        main = "Feature Importance",
        xlab = "Score",
        xlim=range(pretty(c(0, Eval_table))),
        #ylab = "Features",
        horiz = TRUE,
        col = c("lightblue"), 
        beside = TRUE,cex.names = 0.7,
        las=1,
        font.axis=2,
        cex.axis=1,
        cex.lab=1.5 
)

########################################################################################################################################################################################
#LASSO Feature Importance
Sort_index =  order(Classification_Results_LASSO_Ranked_features$Score[2:LASSO_Index],decreasing = FALSE)
Eval_table <-  matrix(Classification_Results_LASSO_Ranked_features$Score[Sort_index], nrow=1)
#rownames(Eval_table) <- c("Training",Validation,"Independent Testing")
colnames(Eval_table) <- Classification_Results_LASSO_Ranked_features$Ranked_feature_List[Sort_index]

# Increase margin size
par(mar=c(4,15,4,4))
barplot(Eval_table,
        main = "Feature Importance",
        xlab = "Score",
        xlim=range(pretty(c(0, Eval_table))),
        #ylab = "Features",
        horiz = TRUE,
        col = c("lightblue"), 
        beside = TRUE,cex.names = 0.7,
        las=1,
        font.axis=2,
        cex.axis=1,
        cex.lab=1.5 
)

########################################################################################################################################################################################
#GBM Feature Importance
Sort_index =  order(Classification_Results_GBM_Ranked_features$Score[1:GBM_Index],decreasing = FALSE)
Eval_table <-  matrix(Classification_Results_GBM_Ranked_features$Score[Sort_index], nrow=1)
#rownames(Eval_table) <- c("Training",Validation,"Independent Testing")
colnames(Eval_table) <- Classification_Results_GBM_Ranked_features$Ranked_feature_List[Sort_index]

# Increase margin size
par(mar=c(4,15,4,4))
barplot(Eval_table,
        main = "Feature Importance",
        xlab = "Score",
        xlim=range(pretty(c(0, Eval_table))),
        #ylab = "Features",
        horiz = TRUE,
        col = c("lightblue"), 
        beside = TRUE,cex.names = 0.7,
        las=1,
        font.axis=2,
        cex.axis=1,
        cex.lab=1.5 
)

########################################################################################################################################################################################
#RF Feature Importance
Sort_index =  order(Classification_Results_RF_Ranked_features$Score[1:RF_Index],decreasing = FALSE)
Eval_table <-  matrix(Classification_Results_RF_Ranked_features$Score[Sort_index], nrow=1)
colnames(Eval_table) <- Classification_Results_RF_Ranked_features$Ranked_feature_List[Sort_index]

# Increase margin size
par(mar=c(4,15,4,4))
barplot(Eval_table,
        main = "Feature Importance",
        xlab = "Score",
        xlim=range(pretty(c(0, Eval_table))),
        #ylab = "Features",
        horiz = TRUE,
        col = c("lightblue"), 
        beside = TRUE,cex.names = 0.7,
        las=1,
        font.axis=2,
        cex.axis=1,
        cex.lab=1.5,
)