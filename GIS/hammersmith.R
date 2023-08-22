# load the necessary libraries
library(raster)

# Read in the raster
borough_ndsm <- raster("City of London_merged_raster.tif")

# Compute slope in degrees
slope_raster <- terrain(borough_ndsm, opt = "slope", unit = "degrees")

# Now you can identify the flat roof.
# Assuming that a slope of less than 2 degrees is "flat"
flat_roof <- slope_raster < 5

# Calculate the area of each pixel
resol <- res(flat_roof)
pixel_area <- prod(resol) # for square meters

# Calculate the total flat roof area by summing up the flat pixels
num_flat_pixels <- cellStats(flat_roof, sum)
total_flat_area <- num_flat_pixels * pixel_area

print(paste("Total flat roof area: ", total_flat_area, " square meters"))

#################################################################

library(raster)
library(terra) # for conversion of raster to spatRaster

# Read in the raster
borough_ndsm <- raster("City of London_merged_raster.tif")

# Group contiguous cells
clusters <- clump(borough_ndsm, directions=4)

# Convert clusters to terra::SpatRaster for more efficient handling of NA values
clusters_terra <- rast(clusters)

# Compute slope in degrees
slope_raster <- terra::terrain(clusters_terra, "slope", unit = "degrees")

# Identify the flat roofs
flat_roof <- slope_raster < 5

# Get unique building IDs
building_ids <- unique(values(clusters_terra))

# Initialize total flat roof area
total_flat_area <- 0

# Initialize total flat roof area
total_flat_area <- 0

for (id in building_ids) {
  # Skip if ID is NA
  if (is.na(id)) next
  
  # Extract the building raster
  building_borough_ndsm <- clusters_terra == id
  
  # Get the area of a single cell
  cell_area <- prod(res(clusters_terra))
  
  # Get the total number of cells for the building
  total_cells <- sum(as.matrix(values(building_borough_ndsm)), na.rm = TRUE)
  
  # Calculate the total area of the building
  building_area <- total_cells * cell_area
  
  # Skip if building area is less than 50 square meters
  if (building_area < 50) next
  
  # Extract the flat roof raster for this building
  building_flat_roof <- flat_roof * building_borough_ndsm
  
  # Calculate the total flat roof area for this building
  num_flat_pixels <- sum(as.matrix(values(building_flat_roof)), na.rm = TRUE)
  building_flat_area <- num_flat_pixels * cell_area
  
  # Update total flat roof area
  total_flat_area <- total_flat_area + building_flat_area
}


print(paste("Total flat roof area: ", total_flat_area, " square meters"))

######################################################
# Import the required libraries
library(raster)
library(terra)

# Load your raster data
borough_ndsm <- raster("City of London_merged_raster.tif")

# Create a raster where each building has a unique ID using 'clump'
clusters <- clump(borough_ndsm, directions=4)

# Convert to terra::SpatRaster for more efficient handling of NA values
clusters_terra <- rast(clusters)

# Get the area of a single cell
cell_area <- prod(res(clusters_terra))

# Initialize an empty raster to store the results
result <- clusters_terra
result[] <- NA

# Get the unique building IDs
building_ids <- unique(values(clusters))

# Loop over each building
for (id in building_ids) {
  # Skip if ID is NA
  if (is.na(id)) next
  
  # Extract the building raster
  building_r <- clusters_terra == id
  
  # Calculate the area of the building
  building_area <- sum(values(building_r), na.rm=TRUE) * cell_area
  
  # If the building area is greater than 50 square meters, 
  # add it to the result raster
  if (building_area > 50) {
    result[building_r] <- id
  }
}

# Convert back to raster
result_raster <- raster(result)

# Save the result
borough_name <- "City of London_merged_raster"
file_name <- paste0(borough_name, "large_buildings.tif")
writeRaster(result_raster, file_name)

#####################################
# Load the library
library(raster)

# Read in the raster
r <- raster("City of London_merged_raster.tif")

# Group contiguous cells
clusters <- clump(r, directions=4)

# Create a color palette for the first 10 clusters
colors <- rainbow(10)

# Find the total number of clusters
num_clusters <- maxValue(clusters)

# Repeat the color palette for all the clusters
colors <- rep(colors, length.out = num_clusters)

# Plot the clusters with the custom colors
plot(clusters, col = colors)

################################ Assess area first##################
# Load necessary libraries
library(terra)
library(sf)
library(pbapply)
library(pryr) # memory use for linux
library(dplyr)

# Set working directory
setwd("/mnt/data/IC_Project/GIS/result/ndsm_borough_crop")

# Function to process one borough
process_borough <- function(borough_name) {
  # Monitor inter-group progress
  print(paste0(borough_name, " start"))
  
  # Record the start time
  #start_time <- Sys.time()
  
  # Read in the building shapefile for the borough
  buildings <- st_read(paste0(borough_name, ".shp"))
  
  # Union adjacent rooftops
  buildings <- st_union(buildings)
  
  # Calculate the area of each polygon
  buildings$area <- as.numeric(st_area(buildings), "m^2")
  
  # Filter out buildings with area less than 50 square meters
  buildings <- buildings[buildings$area >= 5, ]
  
  # Convert to SpatVector
  buildings <- vect(buildings)
  print("Area filter done")
  
  # Read in the DSM for the borough
  ndsm <- rast(paste0(borough_name, ".tif"))
  
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
  
  gc()
  
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
    # Monitor intra-progress
    print(i)
    # Clean memory
    gc()
  }
  
  # Get the current RAM usage
  #ram_usage <- system("free -m", intern = TRUE) # in gb
  
  # Save the merged raster to a .tif file
  terra::writeRaster(merged_raster, paste0(borough_name, " area_test.tif"))
  
  # Record the end time and calculate the processing time
  #end_time <- Sys.time()
  #processing_time <- difftime(start_time, end_time, units = "mins")
  
  
  # Summary to write to file
  #content1 <- paste0(borough_name, " has ", n_groups, " building groups" , "\n")
  #content2 <- paste0("Time difference of ", processing_time, " mins", "\n")
  #content3 <- paste0(ram_usage[2], "\n")
  
  
  # Open the file
  #summary_file <- file("summary_file_path5", "a")
  
  # Write to the file
  #cat(content1, content2, content3, file = summary_file)
  
  # Close the connection
  #close(summary_file)
  
  # Monitor inter-group progress
  print(paste0(borough_name, " done"))
  
}

### List of boroughs ###
# n_groups below 600
#greater_london_boroughs <- c("City of London", "Camden",  "Hackney", "Hammersmith and Fulham", "Islington", 
#                             "Kensington and Chelsea", "Tower Hamlets", "Westminster")

# n_groups 600 to 1000
#greater_london_boroughs <- c("Haringey", "Kingston upon Thames", "Lambeth", "Southwark")

# n_groups 1000 to 1400
#greater_london_boroughs <- c("Barking and Dagenham", "Brent", "Greenwich", "Harrow", "Hounslow", 
#                             "Lewisham", "Merton", "Newham", "Richmond upon Thames", "Sutton", 
#                             "Waltham Forest", "Wandsworth")

# n_groups 1400 to 1800
#greater_london_boroughs <- c("Barnet", "Bexley", "Ealing", "Enfield", "Havering", "Hillingdon", "Redbridge")

# n_groups 1800 to 2100
#greater_london_boroughs <- c("Bromley", "Croydon")

# test
greater_london_boroughs <- c("Hammersmith and Fulham")

# Process each borough
for (borough in greater_london_boroughs) {
  process_borough(borough)
  gc()
}

###############slope first###################