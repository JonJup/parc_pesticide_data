### --- Clean pesticide data from Saarland --- ### 

#       written: 28.11.2022
# last modified: 28.11.2022
#       Project: PARC - Pesticide data 
#       Purpose: Clean pesticide data from Saarland

# setup -----------------------------------------------
source("R/packages.R")

### log files ---- 
sink.file <- paste0("R/log/",Sys.Date(), "_explore_saarland_log.txt")
sink(file = sink.file);documentPath();sessionInfo();sink(file = NULL);rm(sink.file)
### --------------

# load data -------------------------------------------
data <- read_excel("data/Saarland/raw/SL_PSM_2013-2021.xlsx")

if (file.exists("data/variables.rds")){
        variables <- readRDS("data/variables.rds")
} else {
        variables <- c()
}

# prepare data ----------------------------------------

data[-c(1:3),] |> 
        rename(sample_id = ...1, 
               site_id = ...2,
               x.coord = `Koordinaten (Gauß-Krüger)`,
               y.coord = ...4,
               date    = ...5) |> 
        pivot_longer(cols = !c(sample_id:date), names_to = "compound", values_to = "concentration") |> 
        dplyr::filter(!is.na(concentration)) |> 
        dplyr::filter(!str_detect(concentration, "<")) |> 
        mutate(concentration = as.numeric(concentration),
               date          = as_date(dmy(date)),
               measurement_unit = "µg/l", 
               data.set = "Saarland") -> 
        data
data %<>% mutate(epsg = 31466)
# data |> 
#         st_as_sf(coords = c("x.coord", "y.coord"), crs = data$epsg[1]) -> 
#         st.test 
# mapview(st.test)
setDT(data)
source("R/harmonize_variables.R")
data <- data[!is.na(x.coord) & !is.na(y.coord)]
# save data -------------------------------------------
saveRDS(data, "data/Saarland/pesticide_data_saarland_clean.rds")
saveRDS(variables, "data/variables.rds")
