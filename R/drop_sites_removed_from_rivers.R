# —————————————————————————————————————— #
# ——— Drop Sites removed from rivers ——— # 
# —————————————————————————————————————— #

# Jonathan Jupke (jonjup@protonmail.com)
# 15.12.2023

# setup -----------------------------------------------------------------------------
pacman::p_load(data.table, sf, mapview,magrittr,terra,dplyr)

# load data -------------------------------------------------------------------------
data  <- readRDS("data/combined_data.rds")
river1 <- st_read("D://Arbeit/Data/river_network/CCM2/LAEA_W2000.gdb", layer = "RIVERSEGMENTS")
river2 <- st_read("D://Arbeit/Data/river_network/CCM2/LAEA_W2003.gdb", layer = "RIVERSEGMENTS")
river3 <- st_read("D://Arbeit/Data/river_network/CCM2/LAEA_W2005.gdb", layer = "RIVERSEGMENTS")
germany <- readRDS("D://Arbeit/Data/misc/gadm/gadm36_DEU/gadm36_DEU_0_pk.rds")

# prepare data ----------------------------------------------------------------------
germany %<>% st_as_sf %>% st_transform(crs = st_crs(river1))

rivers <- 
        river1 %<>% 
        bind_rows(river2) %>%
        bind_rows(river3) %>%
        st_crop(germany)

#rm(river1, river2, river3)
# - turn data.table into sf object, with one row per unique site
sites <- unique(data, by = "site_id")
sites <- st_as_sf(sites, coords = c("x.coord", "y.coord"), crs = 3035)
sites <- st_transform(sites, crs = st_crs(river1))

nn_id <- st_nearest_feature(sites, rivers)
distances <- st_distance(sites, rivers[nn_id,], by_element = TRUE)
distances <- units::drop_units(distances)
sites$distances <- distances

sites.join <- select(sites, distances, site_id)
data2 <- left_join(
        data, 
        sites.join, 
        by = "site_id"
)


# save to file ----------------------------------------------------------------------
saveRDS(sites,"data/combined_sites_w_distance.rds")
saveRDS(data2,"data/combined_data_w_distance.rds")
