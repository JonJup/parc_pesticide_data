adjust_crs <- function(x,new.crs){
        
        x.sf <- st_as_sf(x,coords = c("x.coord", "y.coord"), crs = x$epsg[1])
        x.sf <- st_transform(x.sf, crs = new.crs)
        coordinates <- st_coordinates(x.sf)
        x$x.coord <- coordinates[,1]
        x$y.coord <- coordinates[,2]
        return(x)
}