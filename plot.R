# Rscript plot.R outputs/report_months
library(ggplot2)
args <- commandArgs(trailingOnly = TRUE); out <- if (length(args)) args[1] else "outputs/report_months"
d <- read.csv(file.path(out, "predictions.csv"))
d <- subset(d, route == "1A" & model == "Random forest" & partition == "test")
period <- unique(d$period)
if (length(period) != 1 || !nrow(d)) stop("Expected one evaluated period for Route 1A.")
period_label <- switch(period, report_months = "July, August and November sample",
                       source_rows = "Original 119-row sample", stop("Unknown period."))
ggsave(file.path(out, "citybus-holdout.svg"),
  ggplot(d, aes(actual, predicted)) + geom_point(colour = "#234f60", size = 2.5) +
  geom_abline(slope = 1, intercept = 0, colour = "#9e623e", linetype = 2) +
  coord_equal() + theme_minimal(base_size = 12) +
  labs(title = "Route 1A: selected-period holdout", x = "Observed ridership", y = "Predicted ridership",
    subtitle = paste("Disjoint test dates;", period_label)),
  width = 8, height = 5, device = grDevices::svg)
