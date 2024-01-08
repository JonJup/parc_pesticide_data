### --- Clean pesticide data from Bavaria --- ### 

#       written: 18.11.2022
# last modified: 18.11.2022
#       Project: PARC - Pesticide data 
#       Purpose: Clean pesticide data from Bavaria

# setup -----------------------------------------------
source("R/packages.R")

### log files ---- 
sink.file <- paste0("R/log/",Sys.Date(), "_explore_bavaria_log.txt")
sink(file = sink.file);documentPath();sessionInfo();sink(file = NULL);rm(sink.file)
### --------------

# load data -------------------------------------------
files <- dir_ls("data/bavaria/raw_data/")
data.sets <- vector(mode = "list", length = length(files))
for (i in 1:length(files)){
        i.data1 <- fread(files[i], fill = TRUE, skip = 1)
        
        i.data1 <- i.data1[1:8,]
        i.site_id <- as.numeric(unlist(i.data1[4,2]))
        i.site_id <- as.numeric(unlist(i.data1[4,2]))
        i.x.coord <- as.numeric(unlist(i.data1[6,2]))
        i.y.coord <- as.numeric(unlist(i.data1[6,4]))
        
        i.data2 <- fread(files[i], fill = TRUE, skip = 8)
        
        if (unique(str_length(i.data2$Datum)) == 10) {
                i.data2[,date:= ymd(Datum)]
        } else {
                i.data2[,date:= as_date(ymd_hms(Datum))]
        }
        
        #i.data2[,date:= as_date(ymd_hms(Datum))]
        i.data2[,c("Datum", "Prüfstatus") := NULL]
        i.data2 %<>%  pivot_longer(cols = !date, names_to = "compound", values_to = "concentration")
        setDT(i.data2)
        i.data2[,c("site_id", "x.coord", "y.coord") := .(i.site_id, i.x.coord, i.y.coord)]
        i.data2[, compound := str_remove(compound, "\\ \\(\\ m\\ Tiefe\\)")]
        i.data2[, measurement_unit := str_extract(compound, "\\ \\[.*\\]$")]
        i.data2[, compound := str_remove(compound, "\\ \\[.*\\]$")]
        i.data2 <- i.data2[concentration != "",]
        i.data2[concentration == "< BG", concentration := "< LOQ"]
        data.sets[[i]] <- i.data2
        rm(list = ls()[grepl(pattern = "^i\\.", x = ls())])
        rm(i)
}

data <- rbindlist(data.sets)

if (file.exists("data/variables.rds")){
        variables <- readRDS("data/variables.rds")
} else {
        variables <- c()
}
# prepare data ----------------------------------------

# - Drop measurements below LOQ. 
# - As discussed in the meeting on the 02.12.2022, we will keep such 
# - measurements for now. 
#data <- data[!concentration %in% c("< LOD", "< LOQ")]

unique(data$compound)

data[, data.set := "bavaria"]
data[, epsg := 25832]
data[, concentration := str_replace(concentration, ",", "\\.")]
# - concentrations must remain string because of "< LOQ" values
#data[, concentration := as.numeric(concentration)]
data[, date := ymd(date)]
# - harmonize variables across data sets
source("R/harmonize_variables.R")
# - drop sites without coordinates
data <- data[!is.na(x.coord) & !is.na(y.coord)]
# save data -------------------------------------------
saveRDS(data, "data/bavaria/pesticide_data_bavaria_clean.rds")
saveRDS(variables, "data/variables.rds")
