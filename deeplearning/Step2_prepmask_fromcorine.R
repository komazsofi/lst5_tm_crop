library(terra)

# Set working directory
workingdirectory="O:/Nat_Sustain-proj/_user/ZsofiaKoma_au700510/Landsat_crop/landsat5_tm_trial/"
setwd(workingdirectory)

corine_file_1990="O:/Nat_Sustain-proj/_user/ZsofiaKoma_au700510/Landsat_crop/field_data/corine_1990_epgs25832.shp"
smallstudyarea_file="O:/Nat_Sustain-proj/_user/ZsofiaKoma_au700510/Landsat_crop/landsat5_tm_trial/split_15km/img_01.tif"

# Import & clip to extent

corine=vect(corine_file_1990)
smallstudyarea=rast(smallstudyarea_file)

corine_crop=crop(corine, smallstudyarea)

# Create mask (only agriculture 1 others are 0)

corine_crop[corine_crop$code_90!=211] <- 0
corine_crop[corine_crop$code_90==211] <- 1

# Rasterize

corine_crop_rasterized <- rasterize(corine_crop, smallstudyarea,field="code_90",fun=max)

# Export
writeRaster(corine_crop_rasterized,"O:/Nat_Sustain-proj/_user/ZsofiaKoma_au700510/Landsat_crop/landsat5_tm_trial/split_15km/img_01_mask.tif")
  
