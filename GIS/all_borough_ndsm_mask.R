# Load necessary libraries
library(terra)
library(sf)
library(pbapply)
library(pryr) # memory use for linux

# Set working directory
setwd("/mnt/data/IC_Project/GIS/result/ndsm_borough_crop")

# Function to process one borough
process_borough <- function(borough_name) {
  # Monitor inter-group progress
  print(paste0(borough_name, " start"))
  
  # Record the start time
  start_time <- Sys.time()
  
  # Read in the building shapefile for the borough
  buildings <- vect(paste0(borough_name, ".shp"))
  
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
  ram_usage <- system("free -m", intern = TRUE) # in gb
  
  # Save the merged raster to a .tif file
  terra::writeRaster(merged_raster, paste0(borough_name, "_merged_raster.tif"))
  
  # Record the end time and calculate the processing time
  end_time <- Sys.time()
  processing_time <- difftime(start_time, end_time, units = "mins")

  
  # Summary to write to file
  content1 <- paste0(borough_name, " has ", n_groups, " building groups" , "\n")
  content2 <- paste0("Time difference of ", processing_time, " mins", "\n")
  content3 <- paste0(ram_usage[2], "\n")
  
  
  # Open the file
  summary_file <- file("summary_file_path5", "a")
  
  # Write to the file
  cat(content1, content2, content3, file = summary_file)
  
  # Close the connection
  close(summary_file)
  
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
greater_london_boroughs <- c("Bromley", "Croydon")

# Process each borough
for (borough in greater_london_boroughs) {
  process_borough(borough)
  gc()
}
