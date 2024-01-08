# ——————————————————————————————————————————————————————————— #
# ——— Work with combined PARC pesticides data for Germany ——— # 
# ——————————————————————————————————————————————————————————— #

# Jonathan Jupke (jonjup@protonmail.com)
# 15.12.2023

# setup -----------------------------------------------------------------------------
pacman::p_load(data.table, sf, mapview)

# load data -------------------------------------------------------------------------
data <- readRDS("data/combined_data.rds")

# prepare data ----------------------------------------------------------------------
sites <- unique(data, by = "site_id")
sites <- st_as_sf(sites, coords = c("x.coord", "y.coord"), crs = 3035)

# plot ------------------------------------------------------------------------------
mapview(sites)


# save to file ----------------------------------------------------------------------
saveRDS(,"")