### --- Match bio and pesticide data Saxony anhalt --- ### 

#       written: 02.12.22
# last modified: 02.12.22
#       Project: PARC
#       Purpose: Match biological and chemical mintoring data

# TEST 
# Dont Repeat Yourself  
# AUTOMATE 
# DOCUMENT 
# NO BORKEN WINDOWS 
# Design by Contract 
# Fail fast/ defensive programming 

# setup -----------------------------------------------

source("R/packages.R")

### log files ---- 
sink(file = paste0("R/log/",Sys.Date(),"_match_saxony_anhalt_log.txt"))
documentPath();sessionInfo();sink(file = NULL)
### --------------

# load data -------------------------------------------
# call script to load and clean data 
source("R/match_bio_chem/saxony_anhalt_bio.R")

# load pesticide data
chem <- readRDS("data/saxony_anhalt/pesticide_data_saxony_anhalt_clean.rds")

# prepare data ----------------------------------------

# drop old biological samples 
range(chem$year)
bio[, year := lubridate::year(date)]
bio <- bio[year %in% 2007:2022]
site.bio <- unique(bio, by = "site_id")  |> st_as_sf(coords = c("x.coord", "y.coord"), crs = 32632) |> st_transform(crs = 25832)
site.che <- unique(chem, by = "site_id") |> st_as_sf(coords = c("x.coord", "y.coord"), crs = 25832 )

nn <- st_nearest_feature(site.bio, site.che)
site.che.nn <- site.che[nn,]
dist <- st_distance(site.bio, site.che.nn, by_element = T)
close_id <- which(dist < units::as_units(300, "m"))
data.comparison <- 
        data.table(
                bio.id = site.bio$site_id,
                che.id = site.che.nn$site_id,
                distance = dist
        )
samples <- unique(bio, by = "sample_id")
for (i in 1:nrow(samples)){
        if (i == 1)
                out = list()
        i.chem = data.comparison[bio.id == samples$site_id[i], che.id]
        i.dist = data.comparison[bio.id == samples$site_id[i], distance]
        b.date <- bio[sample_id == samples$sample_id[i], unique(date)]
        c.date <- chem[site_id == i.chem, unique(date)]
        diffdates <- b.date - c.date
        minid <- which.min(abs(diffdates))
        diffdates <- diffdates[minid]
        out[[i]] <- data.table(sample.id = samples$sample_id[i], 
                                site.id   = samples$site_id[i],
                                chem.id   = i.chem,
                                distance  = i.dist,
                                time      = diffdates)
        print(i)
}
out2 <- rbindlist(out)
library(ggplot2)
library(units)
out2 |> 
        ggplot(aes(x = distance, y = time)) + 
        geom_point(alpha = .1)
out2[,time := as.numeric(time)]
out2 |> 
        dplyr::filter(time < 10 & time > -10) |> 
        dplyr::filter(distance < as_units(300, "m")) -> 
        out3
ggplot(out3, aes(x = distance, y = time)) + geom_point()

test <- bio[site_id %in% out3$site.id]
sites <- st_as_sf(unique(test, by = "site_id"), coords = c("x.coord", "y.coord"), crs = 25832)
mapview(sites)
# analyze --------------------------------------------

# save data -------------------------------------------