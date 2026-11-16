# Final preparation and audit of the supplied off-campus workbook.
# Targets are the workbook's ridership measure, not asserted to be raw boardings.
read_citybus <- function(path) {
  if (!requireNamespace("readxl", quietly = TRUE)) stop("Install readxl.")
  d <- as.data.frame(readxl::read_excel(path, sheet = 2))
  required <- c("WorkDate", "1A", "2B", "6A", "6B", weather_features)
  if (!all(required %in% names(d))) stop("Workbook is missing required columns.")
  d <- d[, required]
  d$WorkDate <- as.Date(d$WorkDate)
  if (anyNA(d$WorkDate) || anyDuplicated(d$WorkDate)) stop("Dates must be valid and unique.")
  if (!all(vapply(d[-1], is.numeric, logical(1)))) stop("Non-numeric measurement found.")
  if (any(vapply(d[-1], function(x) any(is.infinite(x)), logical(1)))) stop("Infinite measurement found.")
  if (any(vapply(d[c("1A", "2B", "6A", "6B")], function(x) any(x < 0, na.rm = TRUE), logical(1)))) stop("Negative ridership found.")
  d[order(d$WorkDate), , drop = FALSE]
}
audit_citybus <- function(d) {
  do.call(rbind, lapply(names(d)[-1], function(nm) {
    x <- d[[nm]]; v <- x[is.finite(x)]
    q <- quantile(v, c(.25, .75), names = FALSE)
    data.frame(field = nm, records = length(x), observed = length(v),
      missing = sum(!is.finite(x)), distinct_observed = length(unique(v)),
      iqr_flags = sum(v < q[1] - 1.5 * diff(q) | v > q[2] + 1.5 * diff(q)))
  }))
}
# Missing route outcomes stay missing. IQR flags are reviewed, never auto-deleted.
# run.R requires complete weather and excludes missing outcomes before fitting/scoring.
