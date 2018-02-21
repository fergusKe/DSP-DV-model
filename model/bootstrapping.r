library(plotly)
target_file <- "/Users/brianpan/Desktop/data/testdata/test_cases.csv"
dv_data <- read.csv(target_file)
dv_data <- transform(dv_data, group=( ifelse(Count > 2, 2, 1) ) ) 

# EDA
high_risk <- dv_data[dv_data$group==2,]
low_risk <- dv_data[dv_data$group==1,]

plot_ly(x="high", y = ~high_risk$AGE, type = "box", name="high") %>%
add_trace(x="low",y = ~low_risk$AGE, name="low")

remove_cols <- c("ACTIONID", "group", "Count")

draw_cols <-names(dv_data)[! names(dv_data) %in% remove_cols]
for(col_name in draw_cols){
	 table(low_risk[,col_name])
}	
# bootstrap sampling 
# sampling
set.seed(123)
high_risk_sample <- dv_data[which(dv_data$group==2) %>% sample(.,500, replace=T),]
low_risk_sample <- dv_data[which(dv_data$group==1) %>% sample(.,500, replace=T),]

sample_data <- rbind(high_risk_sample, low_risk_sample)
sample_file <- "/Users/brianpan/Desktop/data/model/sample.csv"
write.csv(sample_data, sample_file)