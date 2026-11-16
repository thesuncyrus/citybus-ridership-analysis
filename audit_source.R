# Audit source indexing against the original workbook.
# Rscript audit_source.R workbook.xlsx outputs
source("functions.R"); source("prepare.R")
args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("Supply the original off-campus workbook.")
out <- if (length(args) > 1) args[2] else "outputs"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
d <- read_citybus(args[1])
source_rows <- select_period(d, "source_rows")
source_matrix <- source_rows[c("1A", weather_features)]
legacy_train <- 1:95
legacy_test <- 96:ncol(source_matrix) # Inspect archived expression, not a valid holdout.
report_split <- chronological_split(select_period(d))
source_split <- chronological_split(source_rows)
summarize <- function(name, train_dates, test_dates) data.frame(
  design = name, train_rows = length(train_dates), test_rows = length(test_dates),
  overlapping_dates = length(intersect(train_dates, test_dates)),
  train_first = min(train_dates), train_last = max(train_dates),
  test_first = min(test_dates), test_last = max(test_dates))
audit <- rbind(
  summarize("Archived Week 15 indices", source_rows$WorkDate[legacy_train], source_rows$WorkDate[legacy_test]),
  summarize("Report months; disjoint 80/20", report_split$train$WorkDate, report_split$test$WorkDate),
  summarize("Source rows; disjoint 80/20", source_split$train$WorkDate, source_split$test$WorkDate))
write.csv(audit, file.path(out, "split-audit.csv"), row.names = FALSE)
months <- do.call(rbind, lapply(c("report_months", "source_rows"), function(p) {
  counts <- table(format(select_period(d, p)$WorkDate, "%Y-%m"))
  data.frame(period = p, month = names(counts), rows = as.integer(counts))
}))
write.csv(months, file.path(out, "period-audit.csv"), row.names = FALSE)
stopifnot(audit$overlapping_dates[1] == 71, all(audit$overlapping_dates[2:3] == 0),
  nrow(select_period(d)) == 90, nrow(source_rows) == 119)
print(audit)
