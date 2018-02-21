library(rgdal)
csv_file <- "/Users/brianpan/Desktop/data/imputed_age_DVAS.csv"
dvas <- read.csv(csv_file)
locs <-cbind(dvas$lng, dvas$lat)
colnames(locs) <- c("long", "lat")

Graphpath <- "/Users/brianpan/Desktop/data/town"

tw <- readOGR(dsn = Graphpath, layer = "Village_NLSC_1050715", encoding = "big5")


taipei <- tw[tw$C_Name=="臺北市",] 
li <- SpatialPolygons(taipei@polygons)


tpNames <- as.character(taipei$V_Name)
tNames <- as.character(taipei$T_Name)
df_sp <- SpatialPoints(locs)

districts <- tNames
towns <- tpNames

# district_li <- paste(tNames, tpNames, sep="-")
# 第一變數是點 第二變數是圖資
# over 是r在找範圍內的function 
district <- districts[over(df_sp, li)]
town <- towns[over(df_sp, li)]
output_csv <- cbind(district, town)
write.csv(output_csv, file="/Users/brianpan/Desktop/data/town/district.csv")