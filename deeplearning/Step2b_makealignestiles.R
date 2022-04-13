library(terra)

# Set working directory
workingdirectory="O:/Nat_Sustain-proj/_user/ZsofiaKoma_au700510/Landsat_crop/landsat5_tm_trial2/"
setwd(workingdirectory)

studyarea_file="img_31.tif"
studyarea_file_mask="img_31_mask.tif"

# Import & clip to extent

studyarea=rast(studyarea_file)
studyarea_mask=rast(studyarea_file_mask)

##studyarea_mask_crop=terra:::crop(studyarea_mask, studyarea)

# Make tiles

studyarea_300m <- aggregate(studyarea, fact=50)
studyarea_300m_tiles <- makeTiles(studyarea, studyarea_300m)
studyarea_300m_tiles_mask <- makeTiles(studyarea_mask, studyarea_300m)
