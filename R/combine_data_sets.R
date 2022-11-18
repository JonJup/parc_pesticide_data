## combine data sets 


# setup -----------------------------------------------------------------------------
source("R/packages.R")
source("R/functions.R")

### log files ---- 
sink.file <- paste0("R/log/",Sys.Date(), "_cobine_data_sets_log.txt")
sink(file = sink.file);documentPath();sessionInfo();sink(file = NULL);rm(sink.file)
### --------------


# load data -------------------------------------------------------------------------

bavaria     <- readRDS("data/bavaria/pesticide_data_bavaria_clean.rds")
bavaria[, date := ymd(date)]
brandenburg <- readRDS("data/bandenburg/pesticide_data_brandenburg_clean.rds")
brandenburg[, date := ymd(date)]
nrw         <- readRDS("data/NRW/pesticide_data_nrw_clean.rds")
nrw[, date := ymd(date)]


class(bavaria$date) == class(brandenburg$date)

## adjust coordinates 
data <- list(bavaria, brandenburg, nrw)
data %<>% lapply(adjust_crs, new.crs = 3035)
data <- rbindlist(
        data, 
        use.names = TRUE
)


# save to file ----------------------------------------------------------------------
saveRDS(data, "data/combined_data.rds")

samples <- unique(data, by = "site_id")
samples %<>% st_as_sf(coords = c("x.coord", "y.coord"), crs = 3035)
mapview(samples)
