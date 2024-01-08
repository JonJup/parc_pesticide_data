### --- Clean pesticide data from North Rhine-Westphalia --- ### 

#       written: 18.11.2022
# last modified: 18.11.2022
#       Project: PARC - Pesticide data 
#       Purpose: Clean pesticide data from North Rhine-Westphalia

# setup -----------------------------------------------
source("R/packages.R")

### log files ---- 
sink.file <- paste0("R/log/",Sys.Date(), "_explore_nrw_log.txt")
sink(file = sink.file);documentPath();sessionInfo();sink(file = NULL);rm(sink.file)
### --------------

# load data -------------------------------------------
data1 <- read_excel("data/NRW/2022-11-02_PSM_NRW_2012-14.xlsx")
data2 <- read_excel("data/NRW/2022-11-02_PSM_NRW_2015-18.xlsx")
data3 <- read_excel("data/NRW/2022-11-02_PSM_NRW_2019-21.xlsx")

if (file.exists("data/variables.rds")){
        variables <- readRDS("data/variables.rds")
} else {
        variables <- c()
}

# prepare data ----------------------------------------
data1 <- data.table(
        sample_id = data1$Probe,
        site_id = data1$`Messstellen-Nr`,
        x.coord = data1$`Ostwert in UTM`,
        y.coord = data1$`Nordwert in UTM`,
        year    = data1$Jahr,
        date     = data1$Datum, 
        compound = data1$Bezeichnung,
        sample_medium   = data1$Probengut,
        separating_process = data1$Trennverfahren,
        LOQ   = data1$Bestimmungsgrenze,
        concentration = data1$Messergebnis,
        measurement_unit = data1$Einheit
)
data2 <- data.table(
        sample_id = data2$Probe,
        site_id = data2$`Messstellen-Nr`,
        x.coord = data2$`Ostwert in UTM`,
        y.coord = data2$`Nordwert in UTM`,
        year    = data2$Jahr,
        date     = data2$Datum, 
        compound = data2$Bezeichnung,
        sample_medium   = data2$Probengut,
        separating_process = data2$Trennverfahren,
        LOQ   = data2$Bestimmungsgrenze,
        concentration = data2$Messergebnis,
        measurement_unit = data2$Einheit
)
data3 <- data.table(
        sample_id = data3$Probe,
        site_id = data3$`Messstellen-Nr`,
        x.coord = data3$`Ostwert in UTM`,
        y.coord = data3$`Nordwert in UTM`,
        year    = data3$Jahr,
        date     = data3$Datum, 
        compound = data3$Bezeichnung,
        sample_medium   = data3$Probengut,
        separating_process = data3$Trennverfahren,
        LOQ   = data3$Bestimmungsgrenze,
        concentration = data3$Messergebnis,
        measurement_unit = data3$Einheit
)

data <- rbindlist(list(data1, data2, data3))
data[, data.set := "nrw"]
data[, epsg := 25832]
data <- data[str_detect(concentration, "<"), concentration := "< LOQ"]
data <- data[concentration != "qualitativ: negativ"]
data[, concentration := str_replace(concentration, ",", "\\.")]
#data[, concentration := as.numeric(concentration)]
source("R/harmonize_variables.R")
data <- data[!is.na(x.coord) & !is.na(y.coord)]
# save data -------------------------------------------
saveRDS(data, "data/NRW/pesticide_data_nrw_clean.rds")
saveRDS(variables, "data/variables.rds")
