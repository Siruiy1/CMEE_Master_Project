# Install the "raster" package
install.packages("raster")

# Install the "leaflet" package
install.packages("leaflet")

# Install the "sf" package
install.packages("sf")


# Import DSM
library(raster)
dsm <- raster("C:\\Users\\DELL\\OneDrive\\Desktop\\IC project\\GIS\\National-LIDAR-Programme-DSM-2020-TQ28ne\\P_12151\\DSM_TQ2585_P_12151_20201212_20201212.tif")
plot(dsm)

# Import DTM
dtm <- raster("C:\\Users\\DELL\\OneDrive\\Desktop\\IC project\\GIS\\LIDAR-DTM-1m-2022-TQ28ne\\TQ28ne_DTM_1m.tif")
plot(dtm)

# Normalised Digital Surface Model (ndsm)
ndsm <- dsm - dtm

# Set a threshold value for building reclassification
# 3 meters is the height value above which the area is considered as "building" and classify it as 1
min_height_threshold <- 3
# Reclassify NDSM to binary values
m <- c(-Inf, min_height_threshold, 0, min_height_threshold, Inf, 1) # reclassify the values into 2 groups all values < 3 becomes 0, > 3 become 1.
rclmat <- matrix(m, ncol=3, byrow=TRUE)
ndsm_binary <- reclassify(ndsm, rclmat, include.lowest=TRUE)

# Resolution
res(ndsm_binary)
# set the new resolution to 5m
newres <- raster(nrow = 5, ncol = 5)
# resample the raster to the new resolution
extent_ndsm_binary = extent(ndsm_binary)
extent(newres) <- extent_ndsm_binary
r_resampled <- resample(ndsm_binary, newres, method='bilinear')


# Generate a binary mask of building footprints
# convert height mask to polygons using rasterToPolygons
library(sf)
height_polygons <- raster::rasterToPolygons(r_resampled, dissolve = TRUE)
plot(height_polygons)
# Convert binary mask to sf object
building_mask <- sf::st_as_sf(height_polygons)
# Union the polygons to remove overlaps
building_mask_union <- sf::st_union(building_mask)
# Buffer the unioned polygons by -1
building_mask_buffer <- sf::st_buffer(building_mask_union, -1)

# convert ndsm to data frame
ndsm_df <- as.data.frame(ndsm, xy = TRUE)
# convert ndsm to sf object
ndsm_sf <- sf::st_as_sf(ndsm_df, coords = c("x", "y"))

# Perform intersection with ndsm
building_mask_intersection <- sf::st_intersection(building_mask_buffer, ndsm_sf)

# Make valid and convert to polygons
building_polygons <- sf::st_make_valid(sf::st_cast(building_mask_sf_intersection, "POLYGON"))


# buffer the polygons by a negative width to create a negative buffer
buffered_polygons <- sf::st_buffer(sf::st_as_sf(height_polygons), -1)

# union the buffered polygons into a single polygon using st_union
unioned_polygons <- sf::st_union(buffered_polygons)

# rasterize the unioned polygon layer using raster::rasterize
building_mask <- raster::rasterize(sf::st_as_sf(unioned_polygons), ndsm, mask = TRUE)


# convert the binary mask to polygons representing the building footprints
building_polygons <- sf::st_make_valid(sf::st_as_sf(raster::rasterToPolygons(building_mask, dissolve = TRUE)))



# Slope analysis to find flat roofs
slope <- terrain(ndsm, opt='slope')
flat_building <- slope < 5
building_final <- building & flat_building

# Plot the results on a map
library(leaflet)
flat_roof_view <- leaflet() %>%
  addRasterImage(building_final, colors = c("gray", "red"), opacity = 0.8) %>%
  addLegend("topright", colors = c("gray", "red"), labels = c("Not flat roof", "Flat roof"), opacity = 0.8)

# Area of flat roofs
roof_area <- area(building_final) 


### Code (useless) ###
dsm_mean <- focal(ndsm, w=matrix(1,nrow=3,ncol=3),fun=mean, na.rm=T) #create a smoothed DSM

### QUESTIONS ###
# 1. how to define buildings
# 2. To investigate the use of package leaflet
# 3. Find out how to calculate roof area
# 4. Where to get London building footprints