#__________________________________________________________________________________________________________________________________________________________________________________________
#  INSTALLING THE PACKAGES IF NOT INSTALLED
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
packages <- c("survminer","survival","readr","pROC")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))  
  install.packages("caret", dependencies = c("Depends", "Suggests"))
}
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#__________________________________________________________________________________________________________________________________________________________________________________________


library("survminer")
library("readr")
require("survival")
library(pROC)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Figure 5 Kaplan-Meier curve plot
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Read dataframe for Kaplan-Meier plot 
dat=read.csv("./Data/Testing_Dataset_Probability.csv",header=TRUE)

dat$Probability_Class_1<-round(dat$Probability_Class_1,digits=2)

dat$Stage <- ifelse(dat$CTNM.STAGE_0==1, 1,
                ifelse(dat$CTNM.STAGE_1==1,1,
                ifelse(dat$CTNM.STAGE_2==1,2,
                ifelse(dat$CTNM.STAGE_3==1,3,
                ifelse(dat$CTNM.STAGE_4==1,4,NA)))))

dat$quartiles <- ifelse(dat$Probability_Class_1 <0.25,1,
             ifelse((dat$Probability_Class_1 >=0.25 & dat$Probability_Class_1 <0.5),2,
             ifelse((dat$Probability_Class_1 >=0.5 & dat$Probability_Class_1 <0.75),3,
             ifelse(dat$Probability_Class_1 >=0.75,4,NA))))


fit=survfit(Surv(OVERALL.SURVIVAL,VITAL.STATUS) ~ Stage, data = dat)

fit_quartiles=survfit(Surv(OVERALL.SURVIVAL,VITAL.STATUS) ~ quartiles, data = dat)


# Plot survival curve using ML probability as strata
ggsurvplot(fit_quartiles, data = dat, size = 1, palette =c("green","blue", "black", "red"), conf.int = TRUE,          # Add confidence interval
           pval = TRUE, risk.table = FALSE, risk.table.col = "ML Strata", legend.labs =c("0-0.25", "0.25-0.5", "0.5-0.75", "0.75-1.0"),    # Change legend labels
           risk.table.height = 0.25, ggtheme = theme_bw(), xlim=c(0,5.75), break.x.by=1)


#Plot survival curve using stage as strata
ggsurvplot(fit, data = dat, size = 1,  palette =c("green","blue", "black", "red"),conf.int = TRUE,          # Add confidence interval
           pval = TRUE, risk.table = FALSE, risk.table.col = "strata", legend.labs =c("Stage 0-1", "2", "3", "4"),    # Change legend labels
           risk.table.height = 0.25, ggtheme = theme_bw(), xlim=c(0,5.75), break.x.by=1)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Figure 5 ROC curve plot
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
Groundtruth_Results_Test = read_csv('./Data/ROC.csv')

pROC_obj_SVM <- roc(Groundtruth_Results_Test$CLASS,Groundtruth_Results_Test$SVM,
                    # arguments for ci
                    ci=TRUE, ci.alpha=0.95)
plot(pROC_obj_SVM, legacy.axes = TRUE, main = "Independent Testing ROC", print.auc=TRUE, col='darkgreen', print.auc.x = 0.35, print.auc.y = 0.0)

pROC_obj_LASSO <- roc(Groundtruth_Results_Test$CLASS,Groundtruth_Results_Test$LASSO,
                      # arguments for ci
                      ci=TRUE, ci.alpha=0.95)

plot(pROC_obj_LASSO, add=TRUE, col='blue',print.auc=TRUE, print.auc.x = 0.35, print.auc.y = 0.05)

pROC_obj_RF <- roc(Groundtruth_Results_Test$CLASS,Groundtruth_Results_Test$RF,
                   # arguments for ci
                   ci=TRUE, ci.alpha=0.95)
plot(pROC_obj_RF, add=TRUE, col='purple',print.auc=TRUE, print.auc.x = 0.35, print.auc.y = 0.1)


pROC_obj_CART <- roc(Groundtruth_Results_Test$CLASS,Groundtruth_Results_Test$CART,
                     # arguments for ci
                     ci=TRUE, ci.alpha=0.95)
plot(pROC_obj_CART, add=TRUE, col='black',print.auc=TRUE, print.auc.x = 0.35, print.auc.y = 0.15)


pROC_obj_GBM <- roc(Groundtruth_Results_Test$CLASS,Groundtruth_Results_Test$GBM,
                    # arguments for ci
                    ci=TRUE, ci.alpha=0.95)
plot(pROC_obj_GBM, add=TRUE, col='brown',print.auc=TRUE, print.auc.x = 0.35, print.auc.y = 0.2)

legend(x=0.65, y=0.25,bg="transparent", legend=c(  "GBM", "CART","LASSO", "RF","SVM"), 
       col=c('brown', 'black', 'purple', 'blue','darkgreen'), lwd=1, box.lty=0, cex=0.85,
       text.col = c('brown', 'black', 'purple', 'blue','darkgreen'))
grid (NULL,NULL, lty = 6, col = "grey") 

