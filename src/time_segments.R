# Date bounds for the existing Route 1A exploratory experiments.
source("config.R")
citybus_time_segments <- citybus_config$segments

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
