# ———————————————————————————————— #
# ——— Marking samples in lakes ——— # 
# ———————————————————————————————— #

# Jonathan Jupke (jonjup@protonmail.com)
# 08.01.2024

# setup -----------------------------------------------------------------------------
library(groundhog)
pkgs <- c("sf", "dplyr", "data.table")
groundhog.library(pkgs,'2023-12-29')

# load data -------------------------------------------------------------------------
lakes   <- st_read("D://Arbeit/Data/river_network/CCM2/LAEA_Lakes.gdb/", layer = "LAKES")
samples <- readRDS("data/combined_data.rds")

# prepare data ----------------------------------------------------------------------
sites <- unique(samples, by = "site_id")
sites <- st_as_sf(sites, coords = c("x.coord", "y.coord"), crs = 3035)
sites2 <- sites[lakes, ]
samples[, within_lake := FALSE]
samples[site_id %in% sites2$site_id, within_lake := TRUE]

# save to file ----------------------------------------------------------------------
saveRDS(samples,"data/combined_data_w_lakes.rds")