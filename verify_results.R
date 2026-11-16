# Check identities, residual calculations and frozen computed aggregates after a run.
# Historical reported scores are never inputs to fitting or to this check.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "outputs"
source("functions.R")
ref <- read.csv("results/recomputed-metrics.csv")
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
  keys <- c("period", "route", "model", "partition")
  joined <- merge(m, ref[ref$period == period, ], by = keys, suffixes = c("", "_reference"))
  stopifnot(nrow(joined) == nrow(m))
  for (field in c("n", "r_squared", "rmse", "mae"))
    stopifnot(isTRUE(all.equal(joined[[field]], joined[[paste0(field, "_reference")]], tolerance = 1e-7)))
}
early <- read.csv(file.path(out, "early-regression.csv"))
stopifnot(early$n == 29, round(early$r_squared, 3) == .773)
cat("Verified disjoint dates, prediction-derived metrics, both computed reference runs and the 29-row fit.\n")
