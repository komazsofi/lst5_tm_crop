library(terra)

# Set working directory
workingdirectory="O:/Nat_Sustain-proj/_user/ZsofiaKoma_au700510/Landsat_crop/landsat5_tm_trial/"
setwd(workingdirectory)

corine_file_1990="O:/Nat_Sustain-proj/_user/ZsofiaKoma_au700510/Landsat_crop/field_data/corine_1990.shp"

# Import & clip to extent

corine=vect(corine_file_1990)

# Create mask (only agriculture 1 others are 0)

code=211


# Rasterize
  
