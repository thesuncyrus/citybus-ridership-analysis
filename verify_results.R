# Check temporal partitions and prediction-derived metrics after an optional run.
# Metrics are calculated directly from observed outcomes and predictions.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "outputs"
source("functions.R")
for (period in c("report_months", "source_rows")) {
  d <- read.csv(file.path(out, period, "predictions.csv"))
  m <- read.csv(file.path(out, period, "recomputed-metrics.csv"))
  for (route in unique(d$route)) {
    # Use explicit column indexing to avoid data-mask name shadowing.
    tr <- d[d$route == route & d$partition == "train", ]
    te <- d[d$route == route & d$partition == "test", ]
    stopifnot(!length(intersect(tr$date, te$date)), max(tr$date) < min(te$date))
    for (model in unique(d$model)) for (partition in c("train", "test")) {
      rows <- d[d$route == route & d$model == model & d$partition == partition, ]
      saved <- m[m$route == route & m$model == model & m$partition == partition, ]
      stopifnot(nrow(saved) == 1, nrow(rows) == saved$n)
      calc <- regression_metrics(rows$actual, rows$predicted)
      stopifnot(isTRUE(all.equal(unname(calc), as.numeric(saved[c("r_squared", "rmse", "mae")]),
                                tolerance = 1e-9)))
    }
  }

}
early <- read.csv(file.path(out, "early-regression.csv"))
stopifnot(early$n == 29, round(early$r_squared, 3) == .773)
cat("Verified disjoint dates, prediction-derived metrics and the 29-row fit.\n")
