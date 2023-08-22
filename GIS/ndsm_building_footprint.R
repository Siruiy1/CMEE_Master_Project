# Install and load packages
install.packages("raster")
install.packages("rgdal")
install.packages("sf")

library(raster)
library(rgdal)
library(sf)


# Read in ndsm_london_mased.tif and building_footprint london_building_footprint.shp (8 mins)
ndsm_london_masked <- raster("C:/Users/DELL/OneDrive/Desktop/IC project/GIS/LiDAR_data/nDSM/ndsm_london_masked.tif")
london_building_footprint <- read_sf("C:/Users/DELL/OneDrive/Desktop/IC project/GIS/london_building_footprint/london_building_footprint.shp")

# Match ndsm and london_building_footprint CRS
london_building_footprint <- st_transform(london_building_footprint, crs(ndsm_london_masked))

# Mask the ndsm using london_building_footprint
#timer1 <- system.time({
#  ndsm_london_building_masked <- mask(ndsm_london_masked, london_building_footprint)
#})

# Print the run time in seconds (1530.22 )
#print(timer1["elapsed"])  

# ssh -i C:\Users\DELL\OneDrive\Desktop\IC\Oracle\demokey -L 5901:localhost:5901  opc@141.147.73.71
# rsync -Pve "ssh -i C:/Users/DELL/Documents/Oracle/Key/demokey" /cygdrive/c/Users/DELL/Documents/Oracle/File_Transfer/GIS/code/ndsm_building_footprint.R opc@141.147.73.71:/home/opc/


# Parallel Processing (sf library)
# Create unique ID for 'london building footprint'
london_building_footprint$unique_id <- seq_len(nrow(london_building_footprint))

# Split 'london_building_footprint' dataset into chunks
n_chunks <- 32 # Set the number of chunks according to the number of cores available
london_building_footprint$unique_id <- seq_len(nrow(london_building_footprint))
london_building_footprint_chunks <- split(london_building_footprint, cut(london_building_footprint$unique_id, n_chunks, labels = FALSE))

# Set up the parallel processing environment and register the number of cores
library(doParallel)
n_cores <- 32 # Set the number of cores available on your machine
registerDoParallel(cores = n_cores)

# Apply the mask() function in parallel for each chunk
library(raster)
library(foreach)

timer <- system.time({
  ndsm_masked_chunks <- foreach(chunk = london_building_footprint_chunks, .packages = c("raster", "sf")) %dopar% {
    mask(ndsm_london_masked, chunk)
  }
})

# Print the run time in seconds (1530.22 )
print(timer["elapsed"])

# Merge the masked raster chunks back into a single raster
ndsm_london_building_masked <- merge(ndsm_masked_chunks[[1]], ndsm_masked_chunks[[2]])
for (i in 3:length(ndsm_masked_chunks)) {
  ndsm_london_building_masked <- merge(ndsm_london_building_masked, ndsm_masked_chunks[[i]])
}



# Progress Bar
install.packages("progress")
library(progress)

# Create a progress bar object
pb <- progress_bar$new(format = "Completed observation: :iteration |:bar| :percent", total = length(london_building_footprint_chunks), clear = FALSE, width = 60)
# Modify the parallel processing code to update the progress bar after each chunk is completed
ndsm_masked_chunks <- foreach(chunk = london_building_footprint_chunks, .packages = c("raster", "sf")) %dopar% {
  masked_chunk <- mask(ndsm_london_masked, chunk)
  pb$tick()
  masked_chunk
}
