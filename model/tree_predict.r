calc_table <- function(test_data, model){
	cats_Class <- test_data$group
	total <- dim(test_data)[1]
	prob_matrix <- predict(model, test_data)
	cats_pred_Class <- apply( prob_matrix, 1, function(row) return(colnames(prob_matrix)[which(row == max(row))]) )

	rtable <- table(cats_pred_Class,cats_Class)
	rrate <- sum(diag(rtable))/total
	
	return(rtable)
}

# CART predictors
# References: https://c3h3notes.wordpress.com/2010/10/22/r%E4%B8%8A%E7%9A%84cart-package-rpart/
# https://topepo.github.io/caret/recursive-feature-elimination.html#helper-functions
library(rpart)
library(randomForest)
library(randomForestSRC)
library(mlr)
library(dplyr)
par(family="LiHei Pro")

rf_model_file <- "/Users/brianpan/Desktop/data/website/rf_model.RData"
dt_model_file <- "/Users/brianpan/Desktop/data/website/dt_model.RData"
rf_src_model_file <- "/Users/brianpan/Desktop/data/website/rf_src_model.RData"

train_data <- read.csv("/Users/brianpan/Desktop/data/model/sample.csv")
train_data <- na.omit(train_data)
train_data <- transform(train_data, OCCUPATION.無工作=(OCCUPATION=="無工作"))
train_data <- transform(train_data, OCCUPATION.不詳=(OCCUPATION=="不詳"))
train_data$EDUCATION <- factor(train_data$EDUCATION)
train_data$MAIMED <- factor(train_data$MAIMED)
# train_data$被害人婚姻狀態 <- factor(train_data$被害人婚姻狀態)



target_file <- "/Users/brianpan/Desktop/data/testdata/test_cases.csv"
test_data <- read.csv(target_file)
test_data <- transform(test_data, OCCUPATION.無工作=(OCCUPATION=="無工作"))
test_data <- transform(test_data, OCCUPATION.不詳=(OCCUPATION=="不詳"))
test_data <- transform(test_data, group=( ifelse(Count > 2, 2, 1) ) ) 
test_data$EDUCATION <- factor(test_data$EDUCATION)
test_data$MAIMED <- factor(test_data$MAIMED)

tmp_test <- test_data
test_data <- subset(test_data, select=-c(district, town))

# model 
rf_rdata <- "/Users/brianpan/Desktop/data/website/rf_features.RData"
load(rf_rdata)
x <- subset(train_data, select=rf_predictors)
y <- subset(train_data, select=c(group))
rf_train_data <- cbind(x,y)

model_dt <- rpart(group ~  ., data=rf_train_data)
# RandomForest & RandomForestSRC
# http://stats.stackexchange.com/questions/190911/randomforest-vs-randomforestsrc-discrepancies
model_rf <- randomForest(group ~ ., data=rf_train_data)
model_rf_src <-rfsrc(factor(group) ~ ., data=rf_train_data, ntree=500, nodesize=5)

rf_result <- table(train_data$group, round(predict(model_rf, train_data) ))
rf_src_result <- table(train_data$group, round(predict(model_rf_src, train_data)$predicted ))

save(model_rf, file=rf_model_file)
save(model_dt, file=dt_model_file)
save(model_rf_src, file=rf_src_model_file)
# test
# rf_10_result <- calc_table(test_data, model_rf)

dt_test_result <- table(test_data$group, round(predict(model_dt, test_data) ))
rf_test_result <- table(test_data$group, round(predict(model_rf, test_data) ))
rf_src_test_result <- table(test_data$group, round(predict(model_rf_src, test_data)$predicted ))

# 輸出預測的平均 
district_file <- "/Users/brianpan/Desktop/data/results/district.csv"
tmp_test$predict <-predict(model_rf, test_data)
district_sheet <- tmp_test %>% group_by(town) %>% summarise(avg_predict=mean(predict))
write.csv(district_sheet, district_file)

# 輸出沒風險被分為高風險的平均
tmp_test$predict<-predict(model_rf, test_data)

to_extract <-tmp_test[round(tmp_test$predict)==2 & tmp_test$group==1,]

to_extract <- subset(tmp_test, select=c(ACTIONID, Count, predict, group, district, town) )
out<-data.frame(to_extract)
out_file <- "/Users/brianpan/Desktop/data/results/rf_numerical.csv"
write.csv(out, out_file)

reprtree:::plot.getTree(model_rf, k=6)