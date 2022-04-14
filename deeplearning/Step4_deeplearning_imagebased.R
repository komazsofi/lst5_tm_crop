library(keras)
library(tensorflow)
library(tfdatasets)
library(purrr)
library(ggplot2)
library(rsample)
library(stars)
library(raster)
library(reticulate)
library(mapview)

#initiate an empty model
first_model <- keras_model_sequential()
#add first layer, the expected input is of shape 128 by 128 on three channels (we will be dealing with RGB images)
layer_conv_2d(first_model,filters = 32,kernel_size = 3, activation = "relu",input_shape = c(50,50,3))

layer_max_pooling_2d(first_model, pool_size = c(2, 2)) 
layer_conv_2d(first_model, filters = 64, kernel_size = c(3, 3), activation = "relu") 
layer_max_pooling_2d(first_model, pool_size = c(2, 2)) 
layer_conv_2d(first_model, filters = 128, kernel_size = c(3, 3), activation = "relu") 
layer_max_pooling_2d(first_model, pool_size = c(2, 2)) 
layer_conv_2d(first_model, filters = 128, kernel_size = c(3, 3), activation = "relu")
layer_max_pooling_2d(first_model, pool_size = c(2, 2)) 
layer_flatten(first_model) 
layer_dense(first_model, units = 256, activation = "relu")
layer_dense(first_model, units = 1, activation = "sigmoid")

summary(first_model)

# get all file paths of the images containing our target
subset_list <- list.files("O:/Nat_Sustain-proj/_user/ZsofiaKoma_au700510/Landsat_crop/landsat5_tm_trial2/deeplearning_trial1/true", full.names = T)

# create a data.frame with two coloumns: file paths, and the labels (1)
data_true <- data.frame(img=subset_list,lbl=rep(1L,length(subset_list)))

# get all file paths of the images containing non-targets
subset_list <- list.files("O:/Nat_Sustain-proj/_user/ZsofiaKoma_au700510/Landsat_crop/landsat5_tm_trial2/deeplearning_trial1/false", full.names = T)

#creating a data.frame with two coloumns: file paths, and the labels (0)
data_false <- data.frame(img=subset_list,lbl=rep(0L,length(subset_list)))

#merge both data.frames
data <- rbind(data_true,data_false)

# randomly split data set into training (~75%) and validation data (~25%)
# use `lbl` as stratum, so that the split is being done proportional for
# targets and non-targets
set.seed(2020)
data <- initial_split(data,prop = 0.75, strata = "lbl")

c(nrow(training(data)[training(data)$lbl==0,]), nrow(training(data)[training(data)$lbl==1,]))

#prepare training dataset
training_dataset <- tensor_slices_dataset(training(data))

#if you want to get a list of all tensors, you can use the as_iterator() and iterate() functions
dataset_iterator <- as_iterator(training_dataset)
dataset_list <- iterate(dataset_iterator)
#check the first few items of that list, each item one is again a list with two items: img and lbl
head(dataset_list)

#get input shape expected by first_model
subset_size <- first_model$input_shape[2:3]

# apply function on each dataset element: function is list_modify()
#->modify list item "img" three times:

# 1 read decode jpeg
training_dataset <- 
  dataset_map(training_dataset, function(.x)
    list_modify(.x, img = tf$image$decode_jpeg(tf$io$read_file(.x$img))))

# 2 convert data type
training_dataset <- 
  dataset_map(training_dataset, function(.x)
    list_modify(.x, img = tf$image$convert_image_dtype(.x$img, dtype = tf$float32)))

# 3 resize to the size expected by model
training_dataset <- 
  dataset_map(training_dataset, function(.x)
    list_modify(.x, img = tf$image$resize(.x$img, size = shape(subset_size[1], subset_size[2]))))

training_dataset <- dataset_shuffle(training_dataset, buffer_size = 10L*128)
training_dataset <- dataset_batch(training_dataset, 10L)
training_dataset <- dataset_map(training_dataset, unname)

dataset_iterator <- as_iterator(training_dataset)
dataset_list <- iterate(dataset_iterator)
dataset_list[[1]][[1]]

dataset_list[[1]][[1]]$shape
dataset_list[[1]][[2]]

#validation
validation_dataset <- tensor_slices_dataset(testing(data))

validation_dataset <- 
  dataset_map(validation_dataset, function(.x)
    list_modify(.x, img = tf$image$decode_jpeg(tf$io$read_file(.x$img))))

validation_dataset <- 
  dataset_map(validation_dataset, function(.x)
    list_modify(.x, img = tf$image$convert_image_dtype(.x$img, dtype = tf$float32)))

validation_dataset <- 
  dataset_map(validation_dataset, function(.x)
    list_modify(.x, img = tf$image$resize(.x$img, size = shape(subset_size[1], subset_size[2]))))

validation_dataset <- dataset_batch(validation_dataset, 10L)
validation_dataset <- dataset_map(validation_dataset, unname)

compile(
  first_model,
  optimizer = optimizer_rmsprop(lr = 5e-5),
  loss = "binary_crossentropy",
  metrics = "accuracy"
)

diagnostics <- fit(first_model,
                   training_dataset,
                   epochs = 15,
                   validation_data = validation_dataset)

plot(diagnostics)

predictions <- predict(first_model,validation_dataset)
head(predictions)

img_path <- as.character(testing(data)[[1,1]])
img <- stack(img_path)

# load vgg16 as basis for feature extraction
vgg16_feat_extr <- application_vgg16(include_top = F,input_shape = c(50,50,3),weights = "imagenet")
#freeze weights
freeze_weights(vgg16_feat_extr)
#use only layers 1 to 15
pretrained_model <- keras_model_sequential(vgg16_feat_extr$layers[1:15])



# add flatten and dense layers for classification 
# -> these dense layers are going to be trained on our data only
pretrained_model <- layer_flatten(pretrained_model)
pretrained_model <- layer_dense(pretrained_model,units = 256,activation = "relu")
pretrained_model <- layer_dense(pretrained_model,units = 1,activation = "sigmoid")



pretrained_model

compile(
  pretrained_model,
  optimizer = optimizer_rmsprop(lr = 1e-5),
  loss = "binary_crossentropy",
  metrics = c("accuracy")
)

diagnostics <- fit(pretrained_model,
                   training_dataset,
                   epochs = 6,
                   validation_data = validation_dataset)
plot(diagnostics)


