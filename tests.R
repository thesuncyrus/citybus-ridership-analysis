# Meaningful checks for calendar selection, temporal separation and R-squared.
source("functions.R")
d <- data.frame(WorkDate = seq(as.Date("2023-01-01"), as.Date("2023-12-31"), by = "day"))
selected <- select_period(d)
stopifnot(nrow(selected) == 92, all(format(selected$WorkDate, "%m") %in% c("07", "08", "11")))
s <- chronological_split(selected[nrow(selected):1, , drop = FALSE])
stopifnot(nrow(s$train) == floor(.8 * nrow(selected)),
  !length(intersect(s$train$WorkDate, s$test$WorkDate)),
  max(s$train$WorkDate) < min(s$test$WorkDate))
y <- 1:10; wrong <- y + 100
stopifnot(regression_metrics(y, y)["r_squared"] == 1,
  regression_metrics(y, wrong)["r_squared"] < 0, abs(cor(y, wrong)^2 - 1) < 1e-12,
  is.na(regression_metrics(rep(1, 10), rep(1, 10))["r_squared"]))
stopifnot(inherits(try(select_period(d, "unknown"), silent = TRUE), "try-error"))
cat("Period, chronological split and metric checks passed.\n")
