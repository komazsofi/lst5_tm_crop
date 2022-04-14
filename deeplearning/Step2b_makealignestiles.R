library(terra)

# Set working directory
workingdirectory="O:/Nat_Sustain-proj/_user/ZsofiaKoma_au700510/Landsat_crop/landsat5_tm_trial3/"
setwd(workingdirectory)

studyarea_file="LTM5_ndvi_coll.tif"
studyarea_file_mask="LTM5_ndvi_coll_mask.tif"

# Import & clip to extent

studyarea=rast(studyarea_file)
studyarea_mask=rast(studyarea_file_mask)

##studyarea_mask_crop=terra:::crop(studyarea_mask, studyarea)

# Make tiles

dir.create("img")
dir.create("mask")

studyarea_300m <- aggregate(studyarea, fact=112)

setwd("O:/Nat_Sustain-proj/_user/ZsofiaKoma_au700510/Landsat_crop/landsat5_tm_trial3/img/")
studyarea_300m_tiles <- makeTiles(studyarea, studyarea_300m)

setwd("O:/Nat_Sustain-proj/_user/ZsofiaKoma_au700510/Landsat_crop/landsat5_tm_trial3/mask/")
studyarea_300m_tiles_mask <- makeTiles(studyarea_mask, studyarea_300m)
