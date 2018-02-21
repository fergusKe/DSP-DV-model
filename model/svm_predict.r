library(e1071)

train_data <- read.csv("/Users/brianpan/Desktop/data/model/sample.csv")
train_data <- na.omit(train_data)
train_data <- transform(train_data, OCCUPATION.無工作=(OCCUPATION=="無工作"))
train_data <- transform(train_data, OCCUPATION.不詳=(OCCUPATION=="不詳"))

target_file <- "/Users/brianpan/Desktop/testdata/test_cases.csv"
test_data <- read.csv(target_file)
test_data <- na.omit(test_data)

test_data <- transform(test_data, OCCUPATION.無工作=(OCCUPATION=="無工作"))
test_data <- transform(test_data, OCCUPATION.不詳=(OCCUPATION=="不詳"))

# model 
formula_lvq <- factor(Count_plus) ~ 家暴因素.疑似或罹患精神疾病 + 暴力型態.精神暴力 + 求助時間差.小時 + AGE + 家暴因素.照顧壓力 + X8 + 被害人婚姻狀態 + 家暴因素.性生活不協調 + 暴力型態.經濟暴力 + 家暴因素.施用毒品.禁藥或迷幻物品
formula_stepwise <- factor(Count_plus) ~ X14 + OCCUPATION.不詳 + X10 + X13 + X2 + MAIMED + X1.4.5.6 + 家暴因素.照顧壓力 + 高危機.死亡 + 自殺行為
formula_rf_5 <- factor(Count_plus) ~ 求助時間差.小時 + AGE + 受暴持續總月數 + 被害人婚姻狀態 + 成人家庭暴力兩造關係
formula_rf_10 <- factor(Count_plus) ~ 求助時間差.小時 + AGE + 受暴持續總月數 + 被害人婚姻狀態 + 成人家庭暴力兩造關係 + 暴力型態.精神暴力 + EDUCATION + TIPVDA + TIPVDA + 家暴因素.疑似或罹患精神疾病

y <- train_data$group

svm_rdata <- "/Users/brianpan/Desktop/data/svm_features.RData"
load(svm_rdata)

svm_train_x <- subset(train_data, select=svm_predictors) 
svm_train_y <- subset(train_data, select=c(group))
svm_train_data <- cbind(svm_train_x, svm_train_y)
# tune svm
svm_tune <- tune(svm, train.x=svm_train_x, train.y=factor(svm_train_y), kernel="radial", ranges=list(cost=10^(-1:2), gamma=c(0.5,1,2)))
print(svm_tune)

svm_model_after_tune <- svm(formula_stepwise, kernel="radial", cost=as.integer(svm_tune$best.parameters[1]), gamma=as.integer(svm_tune$best.parameters[2]), data=lvq_data)
# summary(svm_model_after_tune)

pred_tune <- predict(svm_model_after_tune, svm_train_x)
train_table <- table(pred_tune, y)

# test set

testset <- test_data

test_y <- testset$group
test_x <- subset(testset, select= svm_predictors)

pred_tune <- predict(svm_model_after_tune, test_x)
test_table <- table(pred_tune, y)