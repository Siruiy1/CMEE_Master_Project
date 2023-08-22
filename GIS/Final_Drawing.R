# Load the necessary libraries
library(raster)
library(rasterVis)

# Read in the raster
borough_ndsm <- raster("City of London_merged_raster.tif")

# Compute slope in degrees
slope_raster <- terrain(borough_ndsm, opt = "slope", unit = "degrees")

# Classify the raster data based on slope
slope_class <- slope_raster
slope_class[] <- ifelse(slope_raster[] < 5, 1, 2)

# Define color palette (Purple for < 5 degrees, Yellow for >= 5 degrees)
cols <- c(rgb(112, 44, 82, maxColorValue=255),"transparent") #rgb(207, 206, 141, maxColorValue=255

writeRaster(slope_class, filename="slope_classification2.tif", format="GTiff", overwrite=TRUE)

# Plot the raster

#levelplot(slope_class, col.regions=cols, at=c(0.5,1.5,2.5), colorkey=FALSE, 
#          scales=list(draw=FALSE), 
#          par.settings=list(axis.line=list(col=NA)))






