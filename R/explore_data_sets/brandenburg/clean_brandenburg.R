### --- Clean pesticide data from Brandenburg --- ### 

#       written: 18.11.2022
# last modified: 18.11.2022
#       Project: PARC - Pesticide data 
#       Purpose: Clean pesticide data from Brandenburg

# setup -----------------------------------------------
source("R/packages.R")
if (file.exists("data/variables.rds")){
        variables <- readRDS("data/variables.rds")
} else {
        variables <- c()
}

### log files ---- 
sink.file <- paste0("R/log/",Sys.Date(), "_explore_brandenburg_log.txt")
sink(file = sink.file);documentPath();sessionInfo();sink(file = NULL);rm(sink.file)
### --------------

# load data -------------------------------------------
measurements <- read_excel("data/bandenburg/LfU_W14_PSM_BB_2015_2022.xlsx", sheet = 1)
sites <- read_excel("data/bandenburg/LfU_W14_PSM_BB_2015_2022.xlsx", sheet = 2)

# prepare data ----------------------------------------
names(measurements) <- c("site_id", "compound", "date", "concentration", "LOQ", "measurement_unit", "drop")
names(sites)        <- c("site_id", "x.coord", "y.coord", "drop1", "drop2", "drop3")

measurements %<>% select(!contains("drop"))
sites %<>% select(!contains("drop"))

data <- left_join(measurements, sites, by = "site_id")
rm(measurements, sites)

setDT(data)
data[, data.set := "brandenburg"]
data[, epsg := 25833]
source("R/harmonize_variables.R")
data <- data[!is.na(x.coord) & !is.na(y.coord)]

# save data -------------------------------------------
saveRDS(data, "data/bandenburg/pesticide_data_brandenburg_clean.rds")
saveRDS(variables, "data/variables.rds")
