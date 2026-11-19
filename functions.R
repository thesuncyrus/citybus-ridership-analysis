# CityBus: ridership and weather analysis.
# Chau Nguyen's project work focused on routes 1A, 2B, 6A and 6B.
# Explicit selected periods, disjoint chronological holdout and consistent metrics.
source("config.R")
weather_features <- citybus_config$weather_features

select_period <- function(d, period = "report_months") {
  d <- d[order(d$WorkDate), , drop = FALSE]
  if (period == "report_months") {
    keep <- format(d$WorkDate, "%Y") == citybus_config$periods$report_year &
      as.integer(format(d$WorkDate, "%m")) %in% citybus_config$periods$report_months
    return(d[keep, , drop = FALSE])
  }
  if (period == "source_rows") {
    if (nrow(d) < max(citybus_config$periods$source_rows)) stop("Source row selection requires the original workbook.")
    return(d[citybus_config$periods$source_rows, , drop = FALSE])
  }
  stop("Period must be report_months or source_rows.")
}
regression_metrics <- function(actual, predicted) {
  stopifnot(
    length(actual) == length(predicted), all(is.finite(actual)),
    all(is.finite(predicted))
  )
  denom <- sum((actual - mean(actual))^2)
  c(
    r_squared = if (denom > 0) 1 - sum((actual - predicted)^2) / denom else NA_real_,
    rmse = sqrt(mean((actual - predicted)^2)), mae = mean(abs(actual - predicted))
  )
}
chronological_split <- function(d, fraction = citybus_config$chronological$train_fraction) {
  stopifnot(fraction > 0, fraction < 1, !anyNA(d$WorkDate))
  d <- d[order(d$WorkDate), , drop = FALSE]
  dates <- sort(unique(d$WorkDate))
  if (length(dates) < 10) stop("At least 10 distinct dates are required.")
  cutoff <- dates[floor(length(dates) * fraction)]
  train <- d[d$WorkDate <= cutoff, , drop = FALSE]
  test <- d[d$WorkDate > cutoff, , drop = FALSE]
  stopifnot(max(train$WorkDate) < min(test$WorkDate))
  list(train = train, test = test, cutoff = cutoff)
}
