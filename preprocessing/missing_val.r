dest_file <- "/Users/brianpan/Desktop/data/model/train2.csv"

setwd("/Users/brianpan/Desktop/data");
getwd();

library(mice);

to_clean <- read.csv("/Users/brianpan/Desktop/data/traindata/train.csv", header=T)
removed <- subset(to_clean, select=c(district, town, ACTIONID))

to_clean <- subset(to_clean, select=- c(district, town, ACTIONID))

# 其餘依照johnson建議以cart完成
mice_method <- rep("cart", 48)
# age 用pmm 補值
imputed_data<-mice(to_clean, m=1, method=mice_method, maxit=15, seed=500)

completed_data <- complete(imputed_data, 1)
writed<- cbind(completed_data, removed)
write.csv(writed, dest_file)
