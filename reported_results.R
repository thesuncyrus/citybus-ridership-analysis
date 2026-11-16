# Transcribe and redraw the final presentation, slide 14.
# These are reported results, NOT outputs of run.R.
library(ggplot2)
args <- commandArgs(trailingOnly = TRUE); out <- if (length(args)) args[1] else "outputs"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
d <- data.frame(model = rep(c("Linear regression", "Decision tree", "Random forest"), each = 2),
  partition = rep(c("Train", "Test"), 3),
  r_squared = c(.2446, .2084, .3121, .2922, .9554, .7546),
  rmse = c(164.50, 162.34, 156.98, 153.51, 93.97, 90.03),
  source = "Original final presentation; slide 14",
  status = "Reported; not independently reproduced as a disjoint holdout")
write.csv(d, file.path(out, "reported-metrics.csv"), row.names = FALSE)
d$model <- factor(d$model, levels = unique(d$model))
d$partition <- factor(d$partition, levels = c("Train", "Test"))
p <- ggplot(d, aes(model, r_squared, fill = partition)) +
  geom_col(position = position_dodge(.75), width = .65) +
  geom_text(aes(label = sprintf("%.4f", r_squared)), position = position_dodge(.75), vjust = -.5, size = 3.5) +
  scale_fill_manual(values = c("#234f60", "#b47e57")) +
  scale_y_continuous(limits = c(0, 1.05), breaks = seq(0, 1, .2)) +
  labs(title = "Market Square: reported model comparison", x = NULL, y = "Reported R-squared",
    fill = NULL, caption = "Source: final presentation, slide 14. See evaluation-method audit.") +
  theme_minimal(base_size = 12) + theme(panel.grid.minor = element_blank(), legend.position = "top")
ggsave(file.path(out, "citybus-reported-comparison.svg"), p, width = 9, height = 5, device = grDevices::svg)
