train_data <- read.csv("/Users/brianpan/Desktop/data/sample.csv")
train_data <- na.omit(train_data)
train_data <- transform(train_data, OCCUPATION.無工作=(OCCUPATION=="無工作"))
train_data <- transform(train_data, OCCUPATION.不詳=(OCCUPATION=="不詳"))
train_data$EDUCATION <- factor(train_data$EDUCATION)
train_data$MAIMED <- factor(train_data$MAIMED)
train_data$group <- ifelse(train_data$group==2, 1, 0)

target_file <- "/Users/brianpan/Desktop/data/train2.csv"
test_data <- read.csv(target_file)
test_data <- transform(test_data, OCCUPATION.無工作=(OCCUPATION=="無工作"))
test_data <- transform(test_data, OCCUPATION.不詳=(OCCUPATION=="不詳"))
test_data <- transform(test_data, group=( ifelse(Count > 2, 1, 0) ) ) 
test_data$EDUCATION <- factor(test_data$EDUCATION)
test_data$MAIMED <- factor(test_data$MAIMED)

rf_rdata <- "/Users/brianpan/Desktop/data/rf_features.RData"
load(rf_rdata)
x <- subset(train_data, select=rf_predictors)
y <- subset(train_data, select=c(group))
rf_train_data <- cbind(x,y)

dv_logit <- glm(group ~ ., data=rf_train_data, family="binomial")
test_data$risks <- predict(dv_logit, newdata=test_data, type="response")

