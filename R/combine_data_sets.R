## combine data sets 


# setup -----------------------------------------------------------------------------
source("R/packages.R")
source("R/functions.R")

### log files ---- 
sink.file <- paste0("R/log/",Sys.Date(), "_cobine_data_sets_log.txt")
sink(file = sink.file);documentPath();sessionInfo();sink(file = NULL);rm(sink.file)
### --------------

# load data -------------------------------------------------------------------------

bavaria            <- readRDS("data/bavaria/pesticide_data_bavaria_clean.rds")
brandenburg        <- readRDS("data/bandenburg/pesticide_data_brandenburg_clean.rds")
hesse              <- readRDS("data/hesse/pesticide_data_hesse_clean.rds")
nrw                <- readRDS("data/NRW/pesticide_data_nrw_clean.rds")
saarland           <- readRDS("data/Saarland/pesticide_data_saarland_clean.rds")
schleswig_holstein <- readRDS("data/schleswig-holstein/pesticide_data_sh_clean.rds")
saxony_anhalt      <- readRDS("data/saxony_anhalt/pesticide_data_saxony_anhalt_clean.rds")

# - fix date 
nrw[, date := ymd(date)]
brandenburg[, date := ymd(date)]
bavaria[, date := ymd(date)]

## adjust coordinates 
data <- list(bavaria, brandenburg, hesse, nrw, saarland, schleswig_holstein, saxony_anhalt)
data %<>% lapply(adjust_crs, new.crs = 3035)
data <- rbindlist(
        data, 
        use.names = TRUE,
        fill = TRUE
)


# save to file ----------------------------------------------------------------------
saveRDS(data, "data/combined_data.rds")

# samples <- unique(data, by = "site_id")
# samples %<>% st_as_sf(coords = c("x.coord", "y.coord"), crs = 3035)
# mapview(samples)
