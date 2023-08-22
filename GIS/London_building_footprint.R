# Load required libraries
library(sf)

# Read in Digimap building file and London boundary file
Digimap_building_combined <- st_read("C:/Users/DELL/OneDrive/Desktop/IC project/GIS/Digimap_building_combined/all_gdb_data_R.shp")
greater_london_boundary <- st_read("C:/Users/DELL/OneDrive/Desktop/IC project/GIS/London boundary")

# Change london boundary Coordinate Reference System to the same as digimap
st_crs(Digimap_building_combined)
st_crs(greater_london_boundary)
greater_london_boundary <- st_transform(greater_london_boundary, st_crs(Digimap_building_combined))

# Start the timer
timer <- system.time({
  # Code to time goes here
  london_building_footprint <- st_intersection(Digimap_building_combined, greater_london_boundary) # Crop Digimap to Greater London Area
})

# Print the run time in seconds
print(timer["elapsed"])


# Save cropped building footprint as new shapefile
st_write(london_building_footprint, "C:/Users/DELL/OneDrive/Desktop/IC project/GIS/london_building_footprint.shp")


