### --- Clean pesticide data from Hesse --- ### 

#       written: 22.11.2022
# last modified: 04.10.2023 (add sample_medium)
#       Project: PARC - Pesticide data 
#       Purpose: Clean pesticide data from Hesse

# setup -----------------------------------------------
source("R/packages.R")

### log files ---- 
sink.file <- paste0("R/log/",Sys.Date(), "_explore_hesse_log.txt")
sink(file = sink.file);documentPath();sessionInfo();sink(file = NULL);rm(sink.file)
### --------------

# load data -------------------------------------------
measurements <- read_excel("data/hesse/raw/Datenabgaben_Export.xlsx", sheet = 1)
sites        <- read_excel("data/hesse/raw/Datenabgaben_Export.xlsx", sheet = 3)

if (file.exists("data/variables.rds")){
        variables <- readRDS("data/variables.rds")
} else {
        variables <- c()
}


# prepare data  ---------------------------------------------------------------------

setDT(measurements)
measurements[, PARAMETER_WERT := as.character(PARAMETER_WERT)]
measurements[!is.na(PARAMETER_VORZEICHEN), PARAMETER_WERT := "< LOQ"]

data <- 
        data.table(
                site_id =as.numeric(measurements$MESSSTELLEN_ID), 
                sample_id = measurements$PROBEN_NR,
                sample_medium = measurements$PROBEN_TYP,
                date = measurements$PROBENAHME_DATUM, 
                compound = measurements$PARAMETER_NAME,
                concentration = measurements$PARAMETER_WERT,
                measurement_unit = measurements$EINHEIT,
                LOQ           = measurements$UNTERE_BESTIMMUNGSGRENZE
        )

data[sample_medium == "Original", sample_medium := "water"]

# - fix date variable 
data[, date := as_date(ymd_hms(date))]
data[, data.set := "hesse"]
data[, epsg := 25832]

# - prepare site data 
sites %<>%
        select(site_id = MST_ID, 
               x.coord = MST_LOKAL_X,
               y.coord = MST_LOKAL_Y)
setDT(sites)
data <- data[sites, on = "site_id"]

#sites <- unique(data, by = "site_id") |> st_as_sf(coords = c("x.coord", "y.coord"), crs = data$epsg[1])
#mapview(sites)

source("R/harmonize_variables.R")
sort(variables)
data <- data[!is.na(x.coord) & !is.na(y.coord)]
# save data -------------------------------------------
saveRDS(data, "data/hesse/pesticide_data_hesse_clean.rds")
saveRDS(variables, "data/variables.rds")
