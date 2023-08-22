# load the necessary libraries
library(raster)

# Read in the raster
borough_ndsm <- raster("City of London_merged_raster.tif")

# Compute slope in degrees
slope_raster <- terrain(borough_ndsm, opt = "slope", unit = "degrees")

# Now you can identify the flat roof.
# Assuming that a slope of less than 2 degrees is "flat"
flat_roof <- slope_raster < 5
writeRaster(flat_roof, filename = "flat1.tif", format = "GTiff", overwrite = TRUE)

# Reclassify existing pixels to 1 and non-pixel areas to 0
r <- flat_roof
r[r == TRUE] <- 1
r[r == FALSE] <- NA

# Create groups/clusters of connected cells
cl <- clump(r)

# Compute the size of each group
sizes <- freq(cl)

# Define your size threshold
threshold <- 1.5  # you can change this to the desired threshold

# Identify the groups that are below the threshold
small_clusters <- sizes[sizes[, 2] < threshold, 1]

# Replace small clusters with NA
r[cl %in% small_clusters] <- NA

# Save the final raster
writeRaster(r, filename = "output8.tif", format = "GTiff", overwrite = TRUE)
