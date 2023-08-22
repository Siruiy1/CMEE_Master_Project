# Install and load packages
install.packages("raster")
install.packages("sf")
library(raster)
library(sf)

# Set working directory
setwd("C:/Users/DELL/OneDrive/Desktop/IC project/GIS")

# Read in DSM and DTM
dsm <- raster("C:/Users/DELL/OneDrive/Desktop/IC project/GIS/LiDAR_Data/DSM/all_dsm_combined.tif")
dtm <- raster("C:/Users/DELL/OneDrive/Desktop/IC project/GIS/LiDAR_Data/DTM/all_dtm_combined.tif")

# Calculate the nDSM
timer <- system.time({
  ndsm <- dsm - dtm
})

# Print the run time in seconds (2301.34)
print(timer["elapsed"])


# Read in London boundary
london_boundary <- st_read("C:/Users/DELL/OneDrive/Desktop/IC project/GIS/London boundary/boundary_greater_london.shp")

# Transform the CRS of the London boundary to match the CRS of the nDSM raster
london_boundary_transformed <- st_transform(london_boundary, crs(ndsm))

# Crop the nDSM to the Greater London area
ndsm_cropped <- crop(ndsm, extent(london_boundary_transformed))

# Mask the nDSM using the London boundary to remove areas outside the boundary
ndsm_masked <- mask(ndsm_cropped, london_boundary_transformed)

# Save
writeRaster(ndsm_masked, "path/to/output/ndsm_cropped.tif", format = "GTiff", overwrite = TRUE)

# Convert the sf object to a SpatVector object
library(terra)
london_building_footprint <- read_sf("C:/Users/DELL/OneDrive/Desktop/IC project/GIS/London_building_footprint/london_building_footprint.shp")
london_building_footprint_sfc <- st_as_sfc(london_building_footprint)
london_building_footprint_sp <- as(london_building_footprint_sfc, "Spatial")
london_building_footprint_vect <- terra::vect(london_building_footprint_sp)

# Save the SpatVector object as a new file
terra::writeVector(london_building_footprint_vect, "london_building_footprint_vect.shp")

########################
# Initialize an empty list to store the converted Spatial objects
london_building_footprint_sp_list <- vector("list", length(london_building_footprint_sfc))

# Loop through the geometries and convert them to Spatial objects
for (i in seq_along(london_building_footprint_sfc)) {
  london_building_footprint_sp_list[[i]] <- as(london_building_footprint_sfc[i], "Spatial")
  cat("Processed geometry:", i, "of", length(london_building_footprint_sfc), "\n")
}

save(london_building_footprint_sp_list, file = "london_building_footprint_sp_list.RData")


# Combine the Spatial objects
# Version that has a progress bar
load("london_building_footprint_sp_list.RData")

# Initialize an empty list to store the converted SpatVector objects
london_building_footprint_vect_list <- vector("list", length(london_building_footprint_sp_list))

# Loop through the Spatial objects and convert them to SpatVector objects
for (i in seq_along(london_building_footprint_sp_list)) {
  london_building_footprint_vect_list[[i]] <- terra::vect(london_building_footprint_sp_list[[i]])
  cat("Processed geometry:", i, "of", length(london_building_footprint_sp_list), "\n")
}

# Combine the SpatVector objects into a single SpatVector
london_building_footprint_vect <- do.call(rbind, london_building_footprint_vect_list)