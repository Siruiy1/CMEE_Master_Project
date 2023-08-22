# Install and load packages
install.packages("raster")
install.packages("rgdal")
install.packages("sf")

library(raster)
library(rgdal)
library(sf)

# Set working directory
working_directory <- "C:/Users/DELL/OneDrive/Desktop/IC project/GIS/LiDAR_Data/DSM"
setwd(working_directory)

# Find all DSM files in the folder and put in a list
dsm_files <- list.files(pattern = "\\.tif$")

# Function to read DSM files
read_dsm <- function(file){
  raster(file)
}

# Apply the read function to all tif files in the folder
all_dsm_read <- lapply(dsm_files, read_dsm) # error at first, because broken file

# Combine all dsm files and time
timer <- system.time({
  merged_dsm <- do.call(merge, all_dsm_read)
})

# Print the run time in seconds (2091.54)
print(timer["elapsed"])

# Save output
output_file <- "all_dsm_combined.tif"

timer2 <- system.time({
  writeRaster(merged_dsm, output_file, format = "GTiff", overwrite = TRUE)
})

# Print the run time in seconds (878.07)
print(timer2["elapsed"])


