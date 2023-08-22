# Load necessary libraries
library(terra)
library(sf)
library(raster)
library(pbapply)

# Read in the building shapefile for one borough
buildings <- vect("Barking and Dagenham.shp")

# Read in the DSM for the same borough
ndsm <- rast("Barking and Dagenham.tif")

# Transform ndsm to the same crs as building
new_crs <- "EPSG:27700"
ndsm <- project(ndsm, new_crs)

# Create a grouping variable
group_size <- 100
n_groups <- ceiling(nrow(buildings)/group_size)
buildings$group <- rep(1:n_groups, each=group_size, length.out=nrow(buildings))

# Split the buildings into groups
building_groups <- split(buildings, buildings$group)

# Define a function to mask a group of buildings
mask_group <- function(group) {
  # Crop the DSM raster to the extent of the group
  ndsm_crop <- crop(ndsm, group)
  
  # Mask the DSM with the building vector
  masked_ndsm <- mask(ndsm_crop, group)
  
  # Return the masked DSM
  return(masked_ndsm)
}

# Use pblapply to apply the function to each group and display a progress bar
masked_dsm_list <- pblapply(building_groups, mask_group)

# Save
# Flatten the list of lists into a single list
flat_list <- unlist(masked_dsm_list, recursive = FALSE)

# Initialize an empty merged raster
merged_raster <- NULL

# Loop over each raster in flat_list
for (i in seq_along(flat_list)) {
  raster <- flat_list[[i]]
  
  # Merge the current raster with the merged_raster
  if (is.null(merged_raster)) {
    merged_raster <- raster
  } else {
    merged_raster <- merge(merged_raster, raster)
  }
  
  print(i)
  
  gc()
  
}

# Save the merged raster to a .tif file
terra::writeRaster(merged_raster, "merged_raster.tif")


####CHECK N_GROUPS FOR EACH BOROUGH####

setwd("C:/Users/DELL/OneDrive/Desktop/IC project/GIS/Borough_Crop")

# Borough names of Greater London
greater_london_boroughs <- c("City of London", "Barking and Dagenham", "Barnet", "Bexley", "Brent",
                             "Bromley", "Camden", "Croydon", "Ealing", "Enfield", "Greenwich",
                             "Hackney", "Hammersmith and Fulham", "Haringey", "Harrow",
                             "Havering", "Hillingdon", "Hounslow", "Islington", "Kensington and Chelsea",
                             "Kingston upon Thames", "Lambeth", "Lewisham", "Merton", "Newham",
                             "Redbridge", "Richmond upon Thames", "Southwark", "Sutton",
                             "Tower Hamlets", "Waltham Forest", "Wandsworth", "Westminster")

for (borough in greater_london_boroughs) {
  # Get file name
  buildings_file_name <- paste0(borough, ".shp")
  
  # Read in the building shapefile for one borough
  buildings <- vect(buildings_file_name)
  
  # Create a grouping variable
  group_size <- 100
  n_groups <- ceiling(nrow(buildings)/group_size)
  
  # Print the number of groups
  message <- paste0(borough, " has ", n_groups, " building groups")
  print(message)
}










