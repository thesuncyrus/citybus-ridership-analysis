# Date bounds for the existing Route 1A exploratory experiments.
citybus_time_segments <- list(
  exploratory = as.Date(c("2023-09-01", "2023-09-30")),
  comparison = as.Date(c("2023-07-01", "2023-11-30")),
  segment_evaluation = as.Date(c("2023-07-01", "2023-08-01"))
)

citybus_segment_rows <- function(d, segment) {
  bounds <- citybus_time_segments[[segment]]
  if (is.null(bounds)) stop("Unknown CityBus time segment.")
  dates <- as.Date(d$WorkDate)
  if (length(dates) != nrow(d) || anyNA(dates) || anyDuplicated(dates))
    stop("Segment selection requires valid, unique WorkDate values.")
  rows <- which(dates >= bounds[1] & dates <= bounds[2])
  if (!length(rows)) stop("No observations in the requested time segment.")
  rows[order(dates[rows])]
}

select_citybus_segment <- function(d, segment) {
  d[citybus_segment_rows(d, segment), , drop = FALSE]
}
