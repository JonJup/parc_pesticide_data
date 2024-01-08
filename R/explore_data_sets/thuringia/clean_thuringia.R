### --- Clean pesticide data from Thuringia --- ### 

#       written: 11.04.2023
# last modified: 11.04.2023
#       Project: PARC - Pesticide data 
#       Purpose: Clean pesticide data from Thuringia

# setup -----------------------------------------------
source("R/packages.R")

conflicts_prefer(lubridate::year)
conflicts_prefer(lubridate::month)
conflicts_prefer(dplyr::filter)
### log files ---- 
sink.file <- paste0("R/log/",Sys.Date(), "_explore_thuringia_log.txt")
sink(file = sink.file);documentPath();sessionInfo();sink(file = NULL);rm(sink.file)
### --------------

# load data -------------------------------------------

coord <- read_xlsx("data/thuringia/Pestizidabfrage Uni Landau J.Jupke_Koordinaten.xlsx")
coord %<>% rename(site_id = Nr.) %>% select(site_id, "UTM Nord", "UTM Ost")
setDT(coord)

data.ls = vector(mode = "list", length = 7)

for (i in 1:7){
        
        i.data <- read_xlsx("data/thuringia/Pestizidabfrage Uni Landau Jonathan Jupke_3.xlsx", sheet = i)
        i.data2 <- data.table(
                sample_id = i.data$`Probe-Nr.`,
                site_id   = i.data$`Mst.-Nr`,
                year      = year(ymd_hms(i.data$Datum)),
                date      = as_date(ymd_hms(i.data$Datum)), 
                compound  = i.data$`Messgröße (lang)`    ,    
                sample_medium = i.data$Medium,
                separating_process = NA,
                LOQ = i.data$Bestimmungsgrenze,
                concentration = i.data$Messwert,
                measurement_unit = i.data$Dimension,
                data.set = "thuringia",
                month = month(ymd_hms(i.data$Datum)),
                comment = i.data$Prüfvermerk
        )
        i.data3 <- coord[i.data2, on = "site_id"]
        i.data3 %<>% rename(y.coord = "UTM Nord", x.coord = "UTM Ost") %>% filter(!is.na(concentration))
        data.ls[[i]] <- i.data3
        rm(list =ls()[grepl(pattern = "^i\\.", x = ls())])
        rm(i)
}
data <-rbindlist(data.ls)
data$epsg <- 25832

unique(data$sample_medium)
data$comment <- NA
data$sample_medium <- "water"
unique(data$compound) %>% sort()

if (file.exists("data/variables.rds")){
        variables <- readRDS("data/variables.rds")
} else {
        variables <- c()
}

# - Assuming the < entries are the LOQs
setDT(data)

sites <- unique(data, by = "site_id") |> st_as_sf(coords = c("x.coord", "y.coord"), crs = data$epsg[1])
mapview(sites)

source("R/harmonize_variables.R")
sort(variables)
data <- data[!is.na(x.coord) & !is.na(y.coord)]
# save data -------------------------------------------
saveRDS(data, "data/thuringia/pesticide_data_th_clean.rds")
saveRDS(variables, "data/variables.rds")
