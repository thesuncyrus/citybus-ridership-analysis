# Date-selection invariance and end-to-end execution on synthetic measurements.
source("src/time_segments.R")
d <- read.csv("data/off_campus_routes.csv",check.names=FALSE)
original_rows <- list(exploratory=240:268,comparison=179:297,segment_evaluation=179:209)
for(segment in names(original_rows)) {
  expected <- as.Date(d$WorkDate[original_rows[[segment]]])
  stopifnot(identical(as.Date(select_citybus_segment(d,segment)$WorkDate),expected))
  shuffled <- d[rev(seq_len(nrow(d))),,drop=FALSE]
  stopifnot(identical(as.Date(select_citybus_segment(shuffled,segment)$WorkDate),expected))
}
# Retain only dates/schema from the input; all measurements below are synthetic.
set.seed(48)
for(name in names(d)[-1]) d[[name]] <- runif(nrow(d),10,100)
d$temp <- d$tempmax * 2
d$feelslike <- d$tempmin * 3
d$precipprob <- d$precipcover * 2
september <- citybus_segment_rows(d,"exploratory")
d$snow[september] <- 0
d$snowdepth[september] <- 0
folder <- tempfile("citybus-exploratory-");dir.create(folder)
input <- file.path(folder,"synthetic.csv")
write.csv(d,input,row.names=FALSE)
log <- file.path(folder,"run.log")
status <- system2(file.path(R.home("bin"),"Rscript"),
  c(shQuote(normalizePath("src/exploratory_weather_regression.R")),
    shQuote(input),shQuote(folder)),stdout=log,stderr=log)
if(status!=0L) stop(paste(tail(readLines(log,warn=FALSE),25),collapse="\n"))
selection <- read.csv(file.path(folder,"row-selection.csv"))
stopifnot(nrow(selection)==29L,
          identical(selection$source_row[!selection$retained],c(242L,262L)),
          sum(selection$retained)==27L,
          file.info(file.path(folder,"exploratory-diagnostics.pdf"))$size>0)
unlink(folder,recursive=TRUE)
cat("Date-selection and synthetic exploratory execution checks passed.\n")
