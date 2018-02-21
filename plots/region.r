library(tidyr)
library(dplyr)
library(ggplot2)

test_data <-read.csv("/Users/brianpan/Desktop/data/results/rf_numerical.csv")
region_data <- read.csv("/Users/brianpan/Desktop/data/plots/各里案件數.csv")
region_data <- subset(region_data[1:455,], select=c(location, 親密關係))
separate_region <- region_data %>% separate(location, c("district", "town"), "區")

town_risks <- aggregate(test_data$predict,by=list(test_data$town), FUN=mean)
names(town_risks)[1] <- "town"

town_risks$town <- as.character(town_risks$town)

# joint_table <- left_join(separate_region, town_risks, by = c("town" = "town") )
joint_table <- merge(x=separate_region, y=town_risks, by="town", all.x=TRUE)

# joint_table <- na.omit(joint_table)
district_cor <- joint_table %>% group_by(district) %>% summarise(cc=cor(親密關係,x, use="complete"))

district_cor <- transform(district_cor, district=paste(district,"區", sep="") )
district_cor$cc <- round(district_cor$cc, 3)
district_cor <- district_cor[order(district_cor[,2], decreasing = TRUE),]

# ggplot 2
# 用factor 轉個彎
# http://rstudio-pubs-static.s3.amazonaws.com/7433_4537ea5073dc4162950abb715f513469.html
district_cor$district <- factor(district_cor$district, levels = district_cor$district[order(district_cor$cc, decreasing=TRUE)])

g <- ggplot(data=district_cor, aes(x=district, y=cc, fill=as.factor(district)) ) 
g <- g+ ylim(c(-0.5, 0.5))
g <- g + geom_bar(stat="identity")+ labs(x="台北市行政區", y="相關係數")
g <- g + theme(legend.title=element_blank()) + theme(text = element_text(family = 'LiHei Pro'))




names(district_cor) <- c("區", "相關係數")
# save(district_cor, file="/Users/brianpan/Desktop/data/district_cor.RData")

# #draw boxplot
draw_cor <- matrix(district_cor$相關係數, nrow=1)
colnames(draw_cor) <- district_cor$區
barplot(draw_cor, ylim =c(-0.5,0.5), legend=T,ylab="相關係數", xlab="台北市行政區")
