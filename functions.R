# CityBus: ridership and weather analysis.
# Chau Nguyen's project work focused on routes 1A, 2B, 6A and 6B.
# Explicit selected periods, disjoint chronological holdout and consistent metrics.
weather_features <- c(
  "tempmax", "tempmin", "temp", "feelslikemax", "feelslikemin",
  "feelslike", "dew", "humidity", "precip", "precipprob", "precipcover", "snow",
  "snowdepth", "windgust", "windspeed", "winddir", "sealevelpressure", "cloudcover",
  "visibility", "solarradiation", "solarenergy", "uvindex", "severerisk", "moonphase"
)
select_period <- function(d, period = "report_months") {
  d <- d[order(d$WorkDate), , drop = FALSE]
  if (period == "report_months") {
    keep <- format(d$WorkDate, "%Y") == "2023" &
      as.integer(format(d$WorkDate, "%m")) %in% c(7, 8, 11)
    return(d[keep, , drop = FALSE])
  }
  if (period == "source_rows") {
    if (nrow(d) < 297) stop("Source row selection requires the original workbook.")
    return(d[179:297, , drop = FALSE])
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
chronological_split <- function(d, fraction = 0.8) {
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
