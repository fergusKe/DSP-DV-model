# random forest 
rf_feature_rdata <- "~/Desktop/data/website/rf_features.RData"
load(rf_feature_rdata)
rf_model_rdata <- "~/Desktop/data/website/rf_model.RData"
load(rf_model_rdata)
rf_src_model_rdata <- "~/Desktop/data/website/rf_src_model.RData"
load(rf_model_rdata)
# decision tree
dt_model_rdata <- "~/Desktop/data/website/dt_model.RData"
load(dt_model_rdata)
# data preprocess

# test
target_file <- "/Users/brianpan/Desktop/data/website/template_v1.csv"
dataframe <- read.csv(target_file)

# preprocess
dataframe <- transform( dataframe, OCCUPATION.無工作=(OCCUPATION == "無工作") )
dataframe <- transform( dataframe, OCCUPATION.不詳=(OCCUPATION == "不詳") )
dataframe <- transform( dataframe, X1.4.5.6=(X1+X4+X5+X6))

# edu hash
edu_hash_file <- "/Users/brianpan/Desktop/data/website/rdata/edu.RData"
edu_hash <- new.env(hash=T)
edu_hash[["不詳"]] <- "1"
edu_hash[["不識字"]] <- "2"
edu_hash[["國中"]] <- "3"
edu_hash[["國小"]] <- "4"
edu_hash[["大學"]] <- "5"
edu_hash[["專科"]] <- "6"
edu_hash[["研究所以上"]] <- "7"
edu_hash[["自修"]] <- "8"
edu_hash[["高中(職)"]] <- "9"
save(edu_hash, file=edu_hash_file)

# MAIMED hash
maimed_hash_file <- "/Users/brianpan/Desktop/data/website/rdata/maimed.RData"
maimed_hash <- new.env(hash=T)
maimed_hash[["非身心障礙者"]] <- "1"
maimed_hash[["疑似身心障礙者"]] <- "2"
maimed_hash[["身心障礙"]] <- "3"
edu_match <- function(x){
	if(x=="" || x=="不詳"){
		NA
	}
	else{
		edu_hash[[x]]
	}
}

maimed_match <- function(x){
	if(x==""){
		NA
	}
	else{
		maimed_hash[[x]]
	}
}

train_data <- read.csv("/Users/brianpan/Desktop/data/model/sample.csv")
train_data <- na.omit(train_data)
train_data <- transform(train_data, OCCUPATION.無工作=(OCCUPATION=="無工作"))
train_data <- transform(train_data, OCCUPATION.不詳=(OCCUPATION=="不詳"))
train_data$EDUCATION <- factor(train_data$EDUCATION)
train_data$MAIMED <- factor(train_data$MAIMED)
train_data <- subset(train_data, select=rf_predictors)

levels(dataframe$EDUCATION) <- sapply( levels(dataframe$EDUCATION), edu_match )
# levels(dataframe$EDUCATION) <- levels(train_data$EDUCATION)
dataframe$EDUCATION <- factor(dataframe$EDUCATION)

levels(dataframe$MAIMED) <- sapply( levels(dataframe$MAIMED), maimed_match )
# levels(dataframe$MAIMED) <- levels(train_data$MAIMED)
dataframe$MAIMED <- factor(dataframe$MAIMED)

dataframe <- subset(dataframe, select=rf_predictors)

# output result
# 先用資料合併讓factor在test data裏都有
new <- rbind( dataframe, train_data )
full_result <- predict( model_rf, new )

# 抓真實測試資料 
test_dim <- dim(dataframe)[1]
rf_test_predict <- full_result[1:test_dim]

rf_src_predict <- round( predict(model_rf_src, new)$predicted )
rf_src_predict <- rf_src_predict[1:test_dim]



