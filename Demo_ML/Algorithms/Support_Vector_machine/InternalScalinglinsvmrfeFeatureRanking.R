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


InternalScalinglinsvmrfeFeatureRanking = function(TrainSample,ytrain,C){
  n = ncol(TrainSample)
  
  survivingFeaturesIndexes = seq(1:n)
  featureRankedList = vector(length=n)
  rankedFeatureIndex = n
  Feature_imp_score = n
  tuned_C <- numeric()
  
  while(length(survivingFeaturesIndexes)>0){
    #train the support vector machine
    svmModel = svm(x=TrainSample[, survivingFeaturesIndexes], y=factor(ytrain), cost = C, cachesize=500,  scale=T, type="C-classification", kernel="linear" )
    #compute the weight vector
    w = t(svmModel$coefs)%*%svmModel$SV
    
    #compute ranking criteria
    rankingCriteria = w * w
    
    #rank the features
    ranking = sort(rankingCriteria, index.return = TRUE)$ix #sorting in decending order
    
    #update feature ranked list
    featureRankedList[rankedFeatureIndex] = survivingFeaturesIndexes[ranking[1]]
    Feature_imp_score[rankedFeatureIndex] = rankingCriteria[ranking[1]]
    rankedFeatureIndex = rankedFeatureIndex - 1
    
    #eliminate the feature with smallest ranking criterion
    (survivingFeaturesIndexes = survivingFeaturesIndexes[-ranking[1]]) 
  }
  Result_list <- list("featureRankedList" = featureRankedList, "Feature_imp_score" = Feature_imp_score)
  #return (featureRankedList, Feature_imp_score) # return list of Ranked features
  return(Result_list)
}
