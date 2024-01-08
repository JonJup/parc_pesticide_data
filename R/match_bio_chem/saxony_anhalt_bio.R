# load data ---------------------------------------------------------------
bio <- fread("bio_data/gld_data/Fliess_Makrozoobenthos_Taxa.csv")
env <- fread("bio_data/gld_data/data.csv")

# reshaping ---------------------------------------------------------------
bio2 <- 
        data.table( 
                sample_id = bio$Probe_Nr,
                site_id   = bio$Mst_Nr_Bio,
                site_id_chem = bio$Mst_Nr_Ch,
                date = dmy(bio$Datum),
                taxon = bio$Taxon,
                abundance = bio$IZ
                )
env2 <- 
        data.table(
                site_id = env$Mst_Nr_Bio, 
                x.coord = env$RW,
                y.coord = env$HW
        )
bio <- bio2[env2, on = "site_id"]

# sites <- unique(data, by = "site_id")
# sites %<>% st_as_sf(coords = c("x.coord", "y.coord"), crs = 32632)
# mapview(sites)
rm(env, env2, bio2)
