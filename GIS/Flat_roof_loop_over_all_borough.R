# load the necessary libraries
library(raster)

# Define the borough list
greater_london_boroughs <- c("City of London", "Barking and Dagenham", "Barnet", "Bexley", "Brent",
                             "Bromley", "Camden", "Croydon", "Ealing", "Enfield", "Greenwich",
                             "Hackney", "Hammersmith and Fulham", "Haringey", "Harrow",
                             "Havering", "Hillingdon", "Hounslow", "Islington", "Kensington and Chelsea",
                             "Kingston upon Thames", "Lambeth", "Lewisham", "Merton", "Newham",
                             "Redbridge", "Richmond upon Thames", "Southwark", "Sutton",
                             "Tower Hamlets", "Waltham Forest", "Wandsworth", "Westminster")

# Initialize an empty dataframe to store results
result <- data.frame(Borough = character(), Size_Exclude_1 = numeric())

# Define your size threshold
threshold <- 2.5

# Iterate over each borough
for (borough in greater_london_boroughs) {
  
  # Read in the raster
  borough_ndsm <- raster(paste0(borough, "_merged_raster.tif"))
  
  # Compute slope in degrees
  slope_raster <- terrain(borough_ndsm, opt = "slope", unit = "degrees")
  
  # Identify the flat roof
  flat_roof <- slope_raster < 5
  
  # Reclassify existing pixels to 1 and non-pixel areas to NA
  r <- flat_roof
  r[r == TRUE] <- 1
  r[r == FALSE] <- NA
  
  # Create groups/clusters of connected cells
  cl <- clump(r)
  
  # Compute the size of each group
  sizes <- freq(cl)
  
  # Identify the groups that are below the threshold
  small_clusters <- sizes[sizes[, 2] < threshold, 1]
  
  # Replace small clusters with NA
  r[cl %in% small_clusters] <- NA
  
  # Compute the remaining size of all clusters
  remaining_size <- sum(getValues(r), na.rm = TRUE)
  
  # Save the final raster
  writeRaster(r, filename = paste0(borough, "_flat_exclude1.tif"), format = "GTiff", overwrite = TRUE)
  
  # Store the borough and the remaining size after excluding the small clusters in the dataframe
  result <- rbind(result, data.frame(Borough = borough, Size_Exclude_2 = remaining_size))
  
  # progress check
  print(paste0(borough, " done!"))
  gc()
}

# Print the final result
print(result)

# Write the dataframe to an Excel file
library(openxlsx)
write.xlsx(result, "Total_London_borough_sizes_2.xlsx")
