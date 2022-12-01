### --- Clean pesticide data from Saxony Anhalt --- ### 

#       written: 21.11.2022
# last modified: 21.11.2022
#       Project: PARC - Pesticide data 
#       Purpose: Clean pesticide data from Saxony Anhalt

# setup -----------------------------------------------
source("R/packages.R")

### log files ---- 
sink.file <- paste0("R/log/",Sys.Date(), "_explore_saxony_anhalt_log.txt")
sink(file = sink.file);documentPath();sessionInfo();sink(file = NULL);rm(sink.file)
### --------------

# load data -------------------------------------------
data_head <- read_excel("data/saxony_anhalt/raw/PBSM_Daten_ab_2007_Stand_20221121.xlsx", skip = 2)
data <- read_excel("data/saxony_anhalt/raw/PBSM_Daten_ab_2007_Stand_20221121.xlsx", skip = 4)
sites <- st_read("data/saxony_anhalt/raw/Fließgewässer.gpkg")

if (file.exists("data/variables.rds")){
        variables <- readRDS("data/variables.rds")
} else {
        variables <- c()
}

unit_vector <- data_head[1,-c(1:11)]
unit_vector <- data.table(compound = names(unit_vector), 
                          measurement_unit = unlist(unit_vector[1,]))
data2 <- copy(data)
setDT(data2)
names(data2)[12:ncol(data2)] <- unit_vector$compound 
data2[, c("Schlüsselnummer", "Gewässer", "PN-Art", "FG_ID", "OWK", "PN-Zeit") := NULL]
data2%<>%rename(site_id = `Mest.-Nr.`,
                sample_id = `Probe-Nr`,
                date      = `PN-Datum`,
                year      = Jahr)
data2[, date := ymd(date)]
data2 <- data2[, names(data2)[which(colSums(is.na(data2)) == nrow(data2))] := NULL]
data2 %<>% pivot_longer(cols = !c("sample_id", "site_id", "date", "year", "Bemerkung"), names_to = "compound", values_to = "concentration", values_transform = as.character)
data2 %<>% 
        dplyr::filter(!is.na(concentration)) %>% 
        dplyr::filter(! concentration %in% c("n.b.", "n.a.", "FALSE", "TRUE")) %>%
        dplyr::filter(!str_detect(concentration, "<")) 

# . check comments 
data2%<>%rename(comment = Bemerkung)

# - add measurement unit 
# mapview(sites)
# data2$site_id %in% sites$mst_nr

sites %<>% 
        select(
                site_id = mst_nr,
                x.coord = rechtswert,
                y.coord = hochwert, 
                ) %>%
        mutate(epsg = 25832) %>%
        st_drop_geometry()

data3 <- left_join(data2, 
          sites, 
          by = "site_id")
setDT(data3)
data3[, data.set := "saxony_anhalt"]

#data[, concentration := str_replace(concentration, ",", "\\.")]
data3[, concentration := as.numeric(concentration)]
# sites <- unique(data, by = "site_id") |> st_as_sf(coords = c("x.coord", "y.coord"), crs = 5652)
# mapview(sites)
data <- data3

source("R/harmonize_variables.R")
sort(variables)
data <- data[!is.na(x.coord) & !is.na(y.coord)]
data[compound == "DICOFOL...22",   compound := "DICOFOL"]
data[compound == "BIFENOX...15",   compound := "BIFENOX"]
data[compound == "QUINOXFEN...96", compound := "QUINOXFEN"]


# save data -------------------------------------------
saveRDS(data, "data/saxony_anhalt/pesticide_data_saxony_anhalt_clean.rds")
saveRDS(variables, "data/variables.rds")
