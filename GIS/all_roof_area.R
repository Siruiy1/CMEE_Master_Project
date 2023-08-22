# Load the required library
library(raster)

# Borough names of Greater London
greater_london_boroughs <- c("City of London", "Barking and Dagenham", "Barnet", "Bexley", "Brent",
                             "Bromley", "Camden", "Croydon", "Ealing", "Enfield", "Greenwich",
                             "Hackney", "Hammersmith and Fulham", "Haringey", "Harrow",
                             "Havering", "Hillingdon", "Hounslow", "Islington", "Kensington and Chelsea",
                             "Kingston upon Thames", "Lambeth", "Lewisham", "Merton", "Newham",
                             "Redbridge", "Richmond upon Thames", "Southwark", "Sutton",
                             "Tower Hamlets", "Waltham Forest", "Wandsworth", "Westminster")

# Since each pixel represents 1m x 1m, the area of each pixel is 1m^2
pixel_area <- 1  # in square meters

# Loop over each borough
for (borough in greater_london_boroughs) {
  
  # Construct the filename
  filename <- paste0(borough, "_merged_raster.tif")
  
  # Check if the file exists
  if (file.exists(filename)) {
    
    # Load the raster file
    ndsm <- raster(filename)
    
    # Calculate the total number of pixels (excluding NA values)
    num_pixels <- sum(!is.na(getValues(ndsm)))
    
    # Calculate the total area
    total_area <- num_pixels * pixel_area
    
    print(paste("Total area of", borough, ":", total_area, "m^2"))
    
  } else {
    message(paste("File not found for borough:", borough))
  }
}
