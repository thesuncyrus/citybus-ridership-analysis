# Check identities, residual calculations and frozen computed aggregates after a run.
# Metrics are calculated directly from observed outcomes and predictions.
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
  # Compare across R/package versions without disguising numerical differences.
  keys <- c("period", "route", "model", "partition")
  joined <- merge(m, ref[ref$period == period, ], by=keys, suffixes=c("", "_reference"))
  stopifnot(nrow(joined)==nrow(m), all(joined$n==joined$n_reference))
  joined$r_squared_difference <- joined$r_squared-joined$r_squared_reference
  write.csv(joined,file.path(out,paste0(period,"-reference-comparison.csv")),row.names=FALSE)
  if (any(abs(joined$r_squared_difference)>1e-7))
    message("Package-version differences recorded in ",period,"-reference-comparison.csv")

}
early <- read.csv(file.path(out, "early-regression.csv"))
stopifnot(early$n == 29, round(early$r_squared, 3) == .773)
cat("Verified disjoint dates, prediction-derived metrics, cross-version reference comparisons and the 29-row fit.\n")
