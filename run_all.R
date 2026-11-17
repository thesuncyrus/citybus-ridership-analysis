# Run the off-campus ridership and weather analysis.
args <- commandArgs(trailingOnly = TRUE)
input <- normalizePath(if(length(args)) args[1] else "data/off_campus_routes.csv", mustWork = TRUE)
out <- if (length(args) > 1) args[2] else "outputs"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
out <- normalizePath(out, mustWork = TRUE)
if (!dir.exists(out)) stop("Output must be a directory.")
rscript <- file.path(R.home("bin"), "Rscript")
run <- function(script, ...) {
  status <- system2(rscript, shQuote(c(script, ...)))
  if (status != 0) stop(paste("Failed stage:", script))
}
run("tests.R")
run("eda.R", input, out)
run("regression_exploration.R", input, out)
for (period in c("report_months", "source_rows")) {
  destination <- file.path(out, period)
  run("run.R", input, destination, period)
  run("diagnostics.R", destination)
  run("plot.R", destination)
}
if (length(args) > 2) run("raw_aggregation.R", normalizePath(args[3], mustWork = TRUE),
                         file.path(out, "campus"))
run("verify_results.R", out)
cat("Completed data audit, EDA, regression, model comparisons, diagnostics and verification.\n")
