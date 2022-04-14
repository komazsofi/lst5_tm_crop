library(terra)

# Set working directory
workingdirectory="O:/Nat_Sustain-proj/_user/ZsofiaKoma_au700510/Landsat_crop/landsat5_tm_trial3/"
setwd(workingdirectory)

corine_file_1990="O:/Nat_Sustain-proj/_user/ZsofiaKoma_au700510/Landsat_crop/field_data/corine_1990_epgs25832.shp"
studyarea_file="O:/Nat_Sustain-proj/_user/ZsofiaKoma_au700510/Landsat_crop/landsat5_tm_trial3/LTM5_ndvi_coll.tif"

# Import & clip to extent

corine=vect(corine_file_1990)
studyarea=rast(studyarea_file)

corine_crop=terra:::crop(corine, studyarea)

# Create mask (only agriculture 1 others are 0)

corine_crop[corine_crop$code_90!=211] <- 0
corine_crop[corine_crop$code_90==211] <- 1

# Rasterize

corine_crop_rasterized <- terra:::rasterize(corine_crop, studyarea,field="code_90",fun=max)

# Export
terra:::writeRaster(corine_crop_rasterized,"O:/Nat_Sustain-proj/_user/ZsofiaKoma_au700510/Landsat_crop/landsat5_tm_trial3/LTM5_ndvi_coll_mask.tif")
  
