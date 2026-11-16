# Replaces repeated manual monthly sums and row-position weather slices in Week 1.R.
# Rscript raw_aggregation.R raw-folder outputs
# Reads the original campus stop-event workbooks and weather file. It does NOT
# reconstruct the separately supplied off-campus modeling workbook.
args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("Usage: Rscript raw_aggregation.R raw-folder [output-directory]")
if (!requireNamespace("readxl", quietly = TRUE)) stop("Install readxl.")
out <- if (length(args) > 1) args[2] else "outputs"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
files <- list.files(args[1], pattern = "Purdue Routes [0-9]{6}\\.xlsx$", full.names = TRUE, recursive = TRUE)
if (!length(files)) stop("No original monthly campus files found.")
all_daily <- list(); audits <- list()
for (f in sort(files)) {
  x <- as.data.frame(readxl::read_excel(f, sheet = 1))
  need <- c("Work Date", "Route", "Boards", "Alights")
  if (!all(need %in% names(x))) stop("Unexpected raw workbook schema.")
  x$date <- as.Date(x[["Work Date"]])
  if (anyNA(x$date) || anyNA(x$Route)) stop("Missing date or route.")
  if (any(x$Boards < 0 | x$Alights < 0, na.rm = TRUE)) stop("Negative event counts.")
  # Do not drop identical events: without a verified event key, duplicates can be real.
  audits[[length(audits) + 1]] <- data.frame(file = basename(f), events = nrow(x),
    exact_repeat_rows = sum(duplicated(x)), missing_board_counts = sum(is.na(x$Boards)),
    missing_alight_counts = sum(is.na(x$Alights)))
  # Preserve missingness in totals instead of turning an unknown count into zero.
  day <- aggregate(x[c("Boards", "Alights")], list(date = x$date, route = x$Route), sum, na.rm = FALSE)
  all_daily[[length(all_daily) + 1]] <- day
}
d <- do.call(rbind, all_daily)
if (anyDuplicated(d[c("date", "route")])) stop("Overlapping monthly source files.")
wfile <- list.files(args[1], pattern = "^KLAF.*\\.xlsx$", full.names = TRUE, recursive = TRUE)
if (length(wfile) != 1) stop("Expected one KLAF weather workbook.")
w <- as.data.frame(readxl::read_excel(wfile, sheet = 1))
w$date <- as.Date(w$datetime)
if (anyNA(w$date) || anyDuplicated(w$date)) stop("Weather dates must be unique.")
if (any(!d$date %in% w$date)) stop("Some boarding dates have no weather record.")
joined <- merge(d, w[c("date", "temp", "humidity", "precip")], by = "date", all.x = TRUE, sort = TRUE)
stopifnot(nrow(joined) == nrow(d))
joined$ridership <- (joined$Boards + joined$Alights) / 2
joined$month <- format(joined$date, "%Y-%m")
totals <- aggregate(joined[c("Boards", "Alights", "ridership")], joined[c("month", "route")], sum, na.rm = FALSE)
counts <- aggregate(joined$date, joined[c("month", "route")], length); names(counts)[3] <- "observed_days"
totals <- merge(totals, counts, by = c("month", "route"))
write.csv(totals, file.path(out, "campus-monthly-boardings.csv"), row.names = FALSE)
write.csv(do.call(rbind, audits), file.path(out, "raw-source-audit.csv"), row.names = FALSE)
# Event and daily records remain local; only route-month aggregates are distributed.
write.csv(joined, file.path(out, "campus-daily-private.csv"), row.names = FALSE)
writeLines(c("Original campus event aggregation, independent of off-campus models.",
  "Months without supplied records are absent, not treated as zero-service months.",
  paste("Input files:", length(files)), capture.output(sessionInfo())), file.path(out, "raw-run-info.txt"))
cat("Aggregated", nrow(d), "route-days from", length(files), "monthly source files.\n")
