# Random Forest transfer between two selected Route 1A time segments.
source("functions.R");source("prepare.R")
args<-commandArgs(trailingOnly=TRUE)
input<-if(length(args)) args[1] else "data/off_campus_routes.csv"
out<-if(length(args)>1) args[2] else "outputs/segment-comparison"
d<-read_citybus(input)
for(route in c("1A","2B","6A","6B")) d[[route]][is.na(d[[route]])]<-mean(d[[route]],na.rm=TRUE)
training<-d[240:268,];test<-d[179:209,]
stopifnot(!length(intersect(training$WorkDate,test$WorkDate)))
ctrl<-caret::trainControl(method="cv",number=3,classProbs=FALSE,
  summaryFunction=caret::defaultSummary,allowParallel=TRUE)
# No fixed seed was specified for this segment experiment; CV/forest fits can vary.
model<-caret::train(`1A`~tempmax+temp+feelslikemax+feelslikemin+feelslike+dew+
  precip+precipcover+sealevelpressure+cloudcover+uvindex+severerisk,
  data=training,method="rf",trControl=ctrl,tuneGrid=expand.grid(mtry=2:6),metric="RMSE")
predictions<-predict(model,test)
metrics<-regression_metrics(test$`1A`,predictions)
dir.create(out,recursive=TRUE,showWarnings=FALSE)
write.csv(data.frame(metric=names(metrics),value=unname(metrics)),file.path(out,"metrics.csv"),row.names=FALSE)
write.csv(data.frame(date=test$WorkDate,actual=test$`1A`,predicted=predictions),file.path(out,"predictions.csv"),row.names=FALSE)
saveRDS(model,file.path(out,"model.rds"))
print(metrics)
