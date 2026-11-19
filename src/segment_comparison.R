# Random Forest transfer between two selected Route 1A time segments.
source("functions.R");source("prepare.R")
source("src/time_segments.R")
args<-commandArgs(trailingOnly=TRUE)
input<-if(length(args)) args[1] else "data/off_campus_routes.csv"
out<-if(length(args)>1) args[2] else "outputs/segment-comparison"
d<-read_citybus(input)
for(route in citybus_config$routes) d[[route]][is.na(d[[route]])]<-mean(d[[route]],na.rm=TRUE)
# Existing segments: September 1-30 (29 rows) and July 1-August 1 (31 rows).
training<-select_citybus_segment(d,citybus_config$segment_forest$train_segment)
test<-select_citybus_segment(d,citybus_config$segment_forest$test_segment)
stopifnot(!length(intersect(training$WorkDate,test$WorkDate)))
ctrl<-caret::trainControl(method=citybus_config$segment_forest$resampling,number=citybus_config$segment_forest$folds,classProbs=FALSE,
  summaryFunction=caret::defaultSummary,allowParallel=TRUE)
# No fixed seed was specified for this segment experiment; CV/forest fits can vary.
model<-caret::train(citybus_config$segment_forest$formula,
  data=training,method="rf",trControl=ctrl,tuneGrid=expand.grid(mtry=citybus_config$segment_forest$mtry),metric="RMSE")
predictions<-predict(model,test)
metrics<-regression_metrics(test$`1A`,predictions)
dir.create(out,recursive=TRUE,showWarnings=FALSE)
write.csv(data.frame(metric=names(metrics),value=unname(metrics)),file.path(out,"metrics.csv"),row.names=FALSE)
write.csv(data.frame(date=test$WorkDate,actual=test$`1A`,predicted=predictions),file.path(out,"predictions.csv"),row.names=FALSE)
saveRDS(model,file.path(out,"model.rds"))
print(metrics)
