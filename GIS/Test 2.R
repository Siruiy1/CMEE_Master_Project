# Install the "raster" package
install.packages("raster")
install.packages("rgdal")
install.packages("sf")
library(rgdal)
library(raster)
library(sf)


# Import DSM
library(raster)
dsm <- raster("C:\\Users\\DELL\\OneDrive\\Desktop\\IC project\\GIS\\National-LIDAR-Programme-DSM-2020-TQ28ne\\P_12151\\DSM_TQ2585_P_12151_20201212_20201212.tif")
plot(dsm)

# Import DTM
dtm <- raster("C:\\Users\\DELL\\OneDrive\\Desktop\\IC project\\GIS\\LIDAR-DTM-1m-2022-TQ28ne\\TQ28ne_DTM_1m.tif")
plot(dtm)

# Normalised Digital Surface Model (ndsm)
ndsm <- dsm - dtm

# Set a threshold value for building reclassification
# 3 meters is the height value above which the area is considered as "building" and classify it as 1
min_height <- 3

# Resample raster to a lower resolution (e.g., 5 meters)
resampled_dsm <- aggregate(ndsm, fact = 5, fun = mean)

# Set all values below the minimum height to NA
resampled_dsm[resampled_dsm < min_height] <- NA

# Calculate slope and aspect of the resampled DSM
slope_raster <- terrain(resampled_dsm, opt = "slope", unit = "degrees")
aspect_raster <- terrain(resampled_dsm, opt = "aspect", unit = "degrees")

# Set threshold values for slope and area
slope_threshold <- 5 # Degrees
area_threshold <- 50 # Square meters

# Create a binary raster based on the slope threshold
binary_slope_raster <- slope_raster < slope_threshold

######################
slope_polygons_test <- rasterToPolygons(binary_slope_raster, dissolve = TRUE)
# Convert to sf object and calculate the area of each polygon
slope_sf <- st_as_sf(slope_polygons_test)
slope_sf$area <- st_area(slope_sf)

# Convert area to a numeric value
slope_sf$area <- as.numeric(slope_sf$area)

# Filter polygons based on the area threshold
filtered_polygons <- slope_sf[slope_sf$area > area_threshold,]
plot(st_geometry(filtered_polygons), col = "blue", border = "blue", lwd = 0.5)

# Calculate the total area of filtered_polygons
total_area <- sum(filtered_polygons$area)

#####################

# Define the number of tiles in x and y direction
tiles_x <- 10
tiles_y <- 10

# Get the extent of the binary slope raster
raster_extent <- extent(binary_slope_raster)

# Calculate the size of each tile
tile_width <- (raster_extent@xmax - raster_extent@xmin) / tiles_x
tile_height <- (raster_extent@ymax - raster_extent@ymin) / tiles_y

# Create an empty list to store the resulting polygons
polygon_list <- list()

# Loop through tiles
for (i in 1:tiles_x) {
  for (j in 1:tiles_y) {
    # Define the extent of the current tile
    xmin <- raster_extent@xmin + (i - 1) * tile_width
    xmax <- raster_extent@xmin + i * tile_width
    ymin <- raster_extent@ymin + (j - 1) * tile_height
    ymax <- raster_extent@ymin + j * tile_height
    tile_extent <- extent(xmin, xmax, ymin, ymax)
    
    # Crop the binary slope raster to the current tile extent
    tile_raster <- crop(binary_slope_raster, tile_extent)
    
    # Perform raster to polygon conversion for the current tile
    tile_polygons <- rasterToPolygons(tile_raster, dissolve = TRUE)
    
    # Add the resulting polygons to the list
    polygon_list[[paste0("tile_", i, "_", j)]] <- tile_polygons
  }
}

# Merge all polygons from the list
slope_polygons <- do.call(rbind, polygon_list)

# Convert to sf object and calculate the area of each polygon
slope_sf <- st_as_sf(slope_polygons)
slope_sf$area <- st_area(slope_sf)

# Convert area to a numeric value
slope_sf$area <- as.numeric(slope_sf$area)

# Filter polygons based on the area threshold
filtered_polygons <- slope_sf[slope_sf$area > area_threshold,]
plot(st_geometry(filtered_polygons), col = "red", border = "red", lwd = 0.5)

# Calculate the total area of filtered_polygons
total_area <- sum(filtered_polygons$area)


# Write the output to a GeoJSON file
output_file <- 'path/to/output.geojson'
st_write(filtered_polygons, output_file, driver = "GeoJSON")
