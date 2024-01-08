### --- Clean pesticide data from Schleswig Holstein --- ### 

#       written: 21.11.2022
# last modified: 21.11.2022
#       Project: PARC - Pesticide data 
#       Purpose: Clean pesticide data from Schleswig Holstein

# setup -----------------------------------------------
source("R/packages.R")

### log files ---- 
sink.file <- paste0("R/log/",Sys.Date(), "_explore_schleswig_holstein_log.txt")
sink(file = sink.file);documentPath();sessionInfo();sink(file = NULL);rm(sink.file)
### --------------

# load data -------------------------------------------
files <- dir_ls("data/schleswig-holstein/raw/")
data <- vector(mode = "list", length = length(files))
for (i in 1:length(files)){
        
        i.x <- read_excel(files[i], sheet = 1)
        setDT(i.x)
        i.x[, file.name := files[i]]
        names(i.x)[1] <- "site_id"
        i.x[, Messstelle := NULL]
        i.x[, date := as_date(ymd_hms(Datum))]
        i.x[, c("Datum", "Probenahme ID") := NULL]
        i.x %<>% rename(x.coord = "UTM-32 East")
        i.x %<>% rename(y.coord = "UTM-32 North")
        i.x %<>% rename(sample_id = "Probe ID")
        i.x %<>% rename(measurement_unit = "Einheit")
        i.x %<>% rename(sample_medium = "Matrix")
        i.x |>  
                pivot_longer(cols = !c("site_id", "file.name","sample_id", "date", "x.coord", "y.coord", "measurement_unit", "sample_medium"), names_to = "compound", values_to = "concentration") |> 
                dplyr::filter(!is.na(concentration)) -> 
                i.x
        data[[i]] <- i.x
        rm(list = ls()[grepl(pattern = "^i\\.", x = ls())])
        
}

data%<>%rbindlist()

if (file.exists("data/variables.rds")){
        variables <- readRDS("data/variables.rds")
} else {
        variables <- c()
}

data[, data.set := "schleswig_holstein"]
data[, epsg := 5652]
data[, concentration := str_replace(concentration, ",", "\\.")]
# - Assuming the < entries are the LOQs
setDT(data)
data[str_detect(concentration, "<"), LOQ := readr::parse_number(concentration)]
us <- data[is.na(LOQ), unique(compound)]
# - creat a vector of unique substances
for (i in us){
        
        i.loq <- data[compound == i & str_detect(concentration, "<")]
        if(nrow(i.loq) == 0) print(i)
        i.min <- i.loq$concentration%>%readr::parse_number()%>%unique%>%min
        data[compound == i & str_detect(concentration, "<", negate = T), LOQ := i.min]
        
        rm(list = ls()[grepl(pattern = "^i\\.", x = ls())])
        rm(i)
}
data[compound == "Metolachlor-SA", LOQ := NA]


# sites <- unique(data, by = "site_id") |> st_as_sf(coords = c("x.coord", "y.coord"), crs = 5652)
# mapview(sites)

source("R/harmonize_variables.R")
sort(variables)
data <- data[!is.na(x.coord) & !is.na(y.coord)]
# save data -------------------------------------------
saveRDS(data, "data/schleswig-holstein/pesticide_data_sh_clean.rds")
saveRDS(variables, "data/variables.rds")
