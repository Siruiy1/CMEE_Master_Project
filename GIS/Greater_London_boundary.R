# London Boundary Data from https://geoportal.statistics.gov.uk/datasets/ons::local-authority-districts-december-2022-boundaries-uk-bfc/explore?location=51.979600%2C0.715402%2C7.07
# Local Authority Districts (December 2022) Names and Codes in the United Kingdom
# Office for National Statistics

# Load required libraries
library(sf)

# Set working directory
setwd("C:/Users/DELL/OneDrive/Desktop/IC project/GIS/Local_Authority_Districts_December_2022_Boundaries_UK_BFC_-6220254555966513740")

# Read shapefiles
UK_local_districts <- st_read("C:/Users/DELL/OneDrive/Desktop/IC project/GIS/Local_Authority_Districts_December_2022_Boundaries_UK_BFC_-6220254555966513740/LAD_DEC_2022_UK_BFC.shp")

# Print attribute table to check
head(UK_local_districts)
names(UK_local_districts)
# All unique districts names
unique(UK_local_districts$LAD22NM)

# Borough names of Greater London
greater_london_boroughs <- c("City of London", "Barking and Dagenham", "Barnet", "Bexley", "Brent",
                             "Bromley", "Camden", "Croydon", "Ealing", "Enfield", "Greenwich",
                             "Hackney", "Hammersmith and Fulham", "Haringey", "Harrow",
                             "Havering", "Hillingdon", "Hounslow", "Islington", "Kensington and Chelsea",
                             "Kingston upon Thames", "Lambeth", "Lewisham", "Merton", "Newham",
                             "Redbridge", "Richmond upon Thames", "Southwark", "Sutton",
                             "Tower Hamlets", "Waltham Forest", "Wandsworth", "Westminster")

# Subset Greater London data from UK data by borough names
greater_london_data <- UK_local_districts[UK_local_districts$LAD22NM %in% greater_london_boroughs, ]

# Save Greater London data as a new shapefile
st_write(greater_london_data, "C:/Users/DELL/OneDrive/Desktop/IC project/GIS/London boundary/boundary_greater_london.shp")
