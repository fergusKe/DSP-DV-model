train_data <- read.csv("/Users/brianpan/Desktop/data/model/sample.csv")
train_data <- na.omit(train_data)

train_data <- transform(train_data, OCCUPATION.無工作=(OCCUPATION=="無工作"))
train_data <- transform(train_data, OCCUPATION.不詳=(OCCUPATION=="不詳"))
train_data$OCCUPATION.無工作 <- factor(train_data$OCCUPATION.無工作)
train_data$OCCUPATION.不詳 <- factor(train_data$OCCUPATION.不詳)

train_data <- subset(train_data, select=-c(Count, OCCUPATION, ACTIONID, district, AGE,TIPVDA, town))
train_data$EDUCATION <- factor(train_data$EDUCATION)
train_data$MAIMED <- factor(train_data$MAIMED)


# train_data$被害人婚姻狀態 <- factor(train_data$被害人婚姻狀態)

# lvq model feature selection

# control <- trainControl(method="repeatedcv", number=10, repeats=3)
# model <- train(factor(Count_plus) ~., data=train_data,
# 				method="lvq", preProcess="scale", trControl=control)

# importance <- varImp(model, scale=FALSE)

# print(importance)
# plot(importance)


# StepWise Backward
# http://www.ats.ucla.edu/stat/r/modules/factor_variables.htm
# AIC: log(likelihood) + 2*(estimators) 愈小愈好
# AIC referece : http://rightthewaygeek.blogspot.tw/2013/10/aic.html

# count_reg <- glm(Count ~ ., data=train_data_stepwise)
# stepFeature <- step(count_reg, direction="backward")

# Random Forest Feature Selection
# Caret references: https://topepo.github.io/caret/recursive-feature-elimination.html
# 變數不可超過53個
#

x <- subset(train_data, select=-c(group))
y <- subset(train_data, select=c(group))

rfControl <- rfeControl(functions=rfFuncs, method="cv", number=10)
RandomForestFeature <- rfe(x, y[,1], c(1:25), rfeControl=rfControl)
rf_predictors <- predictors(RandomForestFeature)
save(rf_predictors, file="/Users/brianpan/Desktop/data/model/rf_features.RData")
