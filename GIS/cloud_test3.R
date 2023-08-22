# Load required packages
library(raster)
library(sf)
library(future.apply)
library(terra)
library(foreach)
library(doParallel)
library(stars)

# Set up future to use multiple cores
#plan(multisession, workers = 2)

# Increase globals limit to 1 GB
#options(future.globals.maxSize = 1024 * 1024 ^ 2)

# Register the parallel backend using the plan function
num_cores <- 2
plan(multisession, workers = num_cores)

# Read input data
ndsm_raster <- terra::rast("C:/path/to/ndsm.tif")
london_building_footprint <- read_sf("C:/path/to/building_footprint.shp")

# Transform london_building_footprint to the CRS of ndsm_london_masked
london_building_footprint_transformed <- st_transform(london_building_footprint, crs(ndsm_raster))

# Define the chunk size and number of chunks
nrow_total <- nrow(london_building_footprint_transformed)
chunk_size <- 10
n_chunks <- ceiling(nrow_total / chunk_size)

# Create a temporary folder to store intermediate results
tmp_dir <- "C:/Users/DELL/OneDrive/Desktop/IC project/GIS/cloud test/tmp"
dir.create(tmp_dir, showWarnings = FALSE) # Add showWarnings = FALSE to suppress warnings if the folder already exists

# Progress File
log_file <- file.path(tmp_dir, "progress.log")

# Define the process_chunk function
process_chunk <- function(chunk, ndsm_raster_file, tmp_dir, chunk_idx, n_chunks) {
  ndsm_raster <- terra::rast(ndsm_raster_file)  # Load the ndsm raster file
  cropped_rasters <- lapply(seq_len(nrow(chunk)), function(i) {
    building <- chunk[i, ]
    building_sp <- as(building, "Spatial")
    building_vect <- terra::vect(building_sp)
    cropped_raster <- terra::mask(ndsm_raster, building_vect)
    return(cropped_raster)
  })
  
  merged_raster <- do.call(terra::merge, cropped_rasters)
  
  tmp_file <- file.path(tmp_dir, paste0("chunk_", chunk_idx, ".tif"))
  terra::writeRaster(merged_raster, tmp_file, filetype = "GTiff", overwrite = TRUE)
  
  cat("Completed chunk", chunk_idx, "of", n_chunks, "\n", file = log_file, append = TRUE)
  return(tmp_file)
}

# Process each chunk in parallel, saving intermediate results to temporary files
ndsm_raster_file <- "C:/Users/DELL/OneDrive/Desktop/IC project/GIS/cloud test/LIDAR-DTM-1m-2022-TQ28ne/TQ28ne_DTM_1m.tif"

tmp_files <- unlist(future_lapply(seq_len(n_chunks), function(chunk_idx) {
  start_idx <- (chunk_idx - 1) * chunk_size + 1
  end_idx <- min(chunk_idx * chunk_size, nrow_total)
  chunk <- london_building_footprint_transformed[start_idx:end_idx, ]
  process_chunk(chunk, ndsm_raster_file, tmp_dir, chunk_idx, n_chunks)
}, future.seed = 123))


# Stop the cluster after the parallel processing is done
stopCluster(cl)

# Merge all masked rasters
ndsm_london_masked_buildings <- do.call(terra::merge, lapply(tmp_files, terra::rast))

# Save the resulting raster to a new file
terra::writeRaster(ndsm_london_masked_buildings, "./data/LiDAR_data/nDSM/ndsm_london_masked_buildings.tif", overwrite = TRUE)

# Remove temporary files and folder
unlink(tmp_files)
unlink(tmp_dir)



