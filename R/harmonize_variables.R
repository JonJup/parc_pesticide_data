# - harmonize variables 

if (!"year" %in% names(data)) data[, year := lubridate::year(date)]
if (!"month" %in% names(data)) data[, month := lubridate::month(date)]
if (!"sample_id" %in% names(data)){
        # add date id 
        data[, date_id := .GRP, by = "date"]
        data[, sample_id := paste0(data.set, site_id, date_id)]
        data[, date_id := NULL]
}


if (!(all(variables %in% names(data))) & !is.null(variables)){
        add_variables <- variables[which(!(variables %in% names(data)))]
        data[, c(add_variables) := NA]
}
if (!(all(names(data) %in% variables))){
        add_names <- names(data)[which(!(names(data) %in% variables))]
        variables <- c(variables, add_names)
}
