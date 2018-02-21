library('caret')
library('mlr')


# svm selection
# catergorical variable 要轉變成dummy codes
# https://cran.r-project.org/web/packages/dummies/dummies.pdf

train_data <- read.csv("/Users/brianpan/Desktop/data/model/sample.csv")
train_data <- na.omit(train_data)
train_data <- subset(train_data, select=-c(Count, OCCUPATION, ACTIONID, district, AGE,TIPVDA, town))

x <- subset(train_data, select=-c(group))
y <- subset(train_data, select=c(group))

svmFeatureSelection <- rfe(x, y[, 1], size=c(15),
						   rfeControl= rfeControl(functions=caretFuncs, number=10),
						   method="svmRadial")
svm_predictors <- predictors(svmFeatureSelection)
save(svm_predictors, file="/Users/brianpan/Desktop/data/svm_features.RData")