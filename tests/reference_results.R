# Optional comparison against the fixed original 29-observation result.
# From the repository root: Rscript tests/reference_results.R outputs
# Reads existing output only; does not fit a model or run with run_all.R.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "outputs"
early <- read.csv(file.path(out, "early-regression.csv"))
stopifnot(nrow(early) == 1, early$n == 29, round(early$r_squared, 3) == .773)
cat("Original 29-observation regression reference check passed.\n")
