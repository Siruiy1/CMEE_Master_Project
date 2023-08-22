# Install the necessary packages
install.packages("rgdal")
install.packages("dplyr")
install.packages("sf")
install.packages("sf", dependencies = TRUE)

# Load Libraries
library(rgdal)
library(dplyr)
library(sf)

# Set the working directory to the folder containing the GDB folders
setwd("C:/Users/DELL/OneDrive/Desktop/IC project/GIS/Digimap_for_combine2")

# Create a list of GDB folder paths
all_gdb_folder_paths <- list.files(pattern = "\\.gdb$", full.names = TRUE)


# Function to read all the layers in a single GDB folder and combine
read_gdb_folder_layers <- function(one_gdb_folder_path){
  # Use 'stlayers()'function from 'rgdal' package
  # List all the layers (eg. tables, fetures classes...) within a specified .gdb folder
  # Save resulting list of layer names as layers
  layers <- st_layers(one_gdb_folder_path)$name
  # Use 'st_read()' function from 'rgdal' package
  # Read layer data from Geodatabase into an R object, save as R_object_layer
  layer_to_R_object <- function(layer){ # the layer input variable is the current element from lapply
    st_read(one_gdb_folder_path, layer = layer)
  }
  gdb_data_R <- lapply(layers, layer_to_R_object)
  # Combine all layers in this gdb folder together
  combined_gdb_data_R <- do.call(rbind, gdb_data_R)
}

# Read and combine all GDB folders
gdb_data_R_each_folder <- lapply(all_gdb_folder_paths, read_gdb_folder_layers)
all_gdb_data_R <- do.call(rbind, gdb_data_R_each_folder) # do.call() is a function allows to call a function using a list of arguments


# Saved combined GDB data
# Save as Shapefile
st_write(all_gdb_data_R, "all_gdb_data_R.shp", layer = "all_gdb_data_R", driver = "ESRI Shapefile")



#### Not particularly useful ####
# Save as GeoJSON
st_write(all_gdb_data_R, "all_gdb_data_R.geojson", driver = "GeoJSON")


# Check whether can save as gdb
library(sf)
gdal_drivers = st_drivers()
"FileGDB" %in% gdal_drivers$name

# Set output GDB folder path
output_gdb_folder <- "output.gdb"

# Save as a new GDB folder
st_write(all_gdb_data_R, dsn = output_gdb_folder, layer = "all_gdb_data_R", driver = "FileGDB", dataset_options = "CREATE_FILEGDB=1.0")






