# Load required packages
library(raster)
library(sf)
library(future.apply)
library(terra)
library(foreach)
library(doParallel)

# Set up future to use multiple cores
#plan(multisession, workers = 2)

# Increase globals limit to 1 GB
#options(future.globals.maxSize = 1024 * 1024 ^ 2)

# Register the parallel backend using the makeCluster and registerDoParallel functions
num_cores <- 2
cl <- makeCluster(num_cores, type = "PSOCK")
registerDoParallel(cl)

# Read input data
ndsm_london_masked <- terra::rast("C:/Users/DELL/OneDrive/Desktop/IC project/GIS/cloud test/LIDAR-DTM-1m-2022-TQ28ne/TQ28ne_DTM_1m.tif")
london_building_footprint <- read_sf("C:/Users/DELL/OneDrive/Desktop/IC project/GIS/cloud test/test_gdb_data_R.shp")

# Transform london_building_footprint to the CRS of ndsm_london_masked
london_building_footprint_transformed <- st_transform(london_building_footprint, crs(ndsm_london_masked))

# Define the chunk size and number of chunks
nrow_total <- nrow(london_building_footprint_transformed)
chunk_size <- 10
n_chunks <- ceiling(nrow_total / chunk_size)

# Create a temporary folder to store intermediate results
tmp_dir <- "C:/Users/DELL/OneDrive/Desktop/IC project/GIS/cloud test/tmp"
dir.create(tmp_dir)

# Define a function to process a single building footprint and mask the ndsm_london_masked raster
process_building <- function(building, ndsm_raster) {
  building_sfc <- st_as_sfc(building)  # Convert sf object to sfc object
  building_sp <- as(building_sfc, "Spatial")  # Convert sfc object to Spatial object
  building_vect <- terra::vect(building_sp)  # Convert SpatialPolygons object to SpatVector object
  masked_raster <- terra::mask(ndsm_raster, building_vect)
  return(masked_raster)
}

# Progress File
log_file <- file.path(tmp_dir, "progress.log")

# Define the process_chunk function
process_chunk <- function(chunk, ndsm_raster_file, tmp_dir, chunk_idx, n_chunks) {
  ndsm_raster <- terra::rast(ndsm_raster_file)  # Load the ndsm raster file
  masked_rasters <- lapply(seq_len(nrow(chunk)), function(i) {
    building <- chunk[i, ]  # Get the building footprint for the current index
    process_building(building, ndsm_raster)  # Mask the ndsm raster using the building footprint
  })
  
  # Merge the masked rasters in the list into a single raster
  merged_raster <- do.call(terra::merge, masked_rasters)
  
  tmp_file <- file.path(tmp_dir, paste0("chunk_", chunk_idx, ".tif"))
  # Save the merged raster to a temporary file
  terra::writeRaster(merged_raster, tmp_file, filetype = "GTiff", overwrite = TRUE)
  
  cat("Completed chunk", chunk_idx, "of", n_chunks, "\n", file = log_file, append = TRUE)
  return(tmp_file)
}


# Process each chunk in parallel, saving intermediate results to temporary files
ndsm_raster_file <- "C:/Users/DELL/OneDrive/Desktop/IC project/GIS/cloud test/LIDAR-DTM-1m-2022-TQ28ne/TQ28ne_DTM_1m.tif"

tmp_files <- unlist(foreach(chunk_idx = seq_len(n_chunks), .combine = c, .packages = c("sf", "terra")) %dopar% {
  start_idx <- (chunk_idx - 1) * chunk_size + 1
  end_idx <- min(chunk_idx * chunk_size, nrow_total)
  chunk <- london_building_footprint_transformed[start_idx:end_idx, ]
  process_chunk(chunk, ndsm_raster_file, tmp_dir, chunk_idx, n_chunks)
})

# Flatten the list of temporary files
tmp_files <- unlist(tmp_files)

# Stop the cluster after the parallel processing is done
stopCluster(cl)

# Merge all masked rasters
ndsm_london_masked_buildings <- do.call(terra::merge, lapply(tmp_files, terra::rast))

# Save the resulting raster to a new file
terra::writeRaster(ndsm_london_masked_buildings, "./data/LiDAR_data/nDSM/ndsm_london_masked_buildings.tif", overwrite = TRUE)

# Remove temporary files and folder
unlink(tmp_files)
unlink(tmp_dir)











####################################################################

library(rgdal)
library(dplyr)
library(sf)
# Saved combined GDB data
# Save as Shapefile
layer <- st_layers("C:/Users/DELL/OneDrive/Desktop/IC project/GIS/cloud test/Download_tq28ne_2256044/mastermap_building_heights_5034765/tq/tq2585.gdb")$name
gdb_data <- st_read("C:/Users/DELL/OneDrive/Desktop/IC project/GIS/cloud test/Download_tq28ne_2256044/mastermap_building_heights_5034765/tq/tq2585.gdb", layer = layer)
st_write(gdb_data, "test_gdb_data_R.shp", layer = "test_gdb_data_R", driver = "ESRI Shapefile")
