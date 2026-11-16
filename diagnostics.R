# Charts from computed selected-period results only; run after run.R.
# Rscript diagnostics.R outputs/report_months
library(ggplot2)
args <- commandArgs(trailingOnly = TRUE); out <- if (length(args)) args[1] else "outputs/report_months"
m <- read.csv(file.path(out, "recomputed-metrics.csv"))
p <- read.csv(file.path(out, "predictions.csv"))
imp <- read.csv(file.path(out, "importance.csv"))
theme_set(theme_minimal(base_size = 12) + theme(panel.grid.minor = element_blank()))
save_plot <- function(name, plot, h = 5) ggsave(file.path(out, name), plot,
  width = 9, height = h, device = svglite::svglite)
test <- subset(m, partition == "test")
save_plot("citybus-model-comparison.svg", ggplot(test, aes(model, rmse, fill = model)) +
  geom_col(width = .65) + facet_wrap(~route, scales = "free_y") +
  labs(title = "Selected-period reconstruction: test errors", subtitle = unique(m$period),
    x = NULL, y = "Test RMSE", caption = "Chronological 80/20; disjoint dates. Same observed test outcomes for each model.") +
  theme(legend.position = "none", axis.text.x = element_text(angle = 20, hjust = 1)))
top <- subset(imp, route == "1A"); top <- head(top[order(-top$decrease_node_impurity), ], 10)
save_plot("citybus-importance.svg", ggplot(top, aes(reorder(feature, decrease_node_impurity), decrease_node_impurity)) +
  geom_col(fill = "#234f60") + coord_flip() + labs(title = "Route 1A: fitted forest importance",
    x = NULL, y = "Total decrease in node impurity",
    caption = "Regression impurity is residual sum of squares, not classification Gini. Not causal."))
forest <- subset(p, model == "Random forest" & partition == "test")
forest$residual <- forest$actual - forest$predicted
save_plot("citybus-residuals.svg", ggplot(forest, aes(predicted, residual)) +
  geom_point(colour = "#234f60", size = 2) + geom_hline(yintercept = 0, linetype = 2) +
  facet_wrap(~route, scales = "free") +
  labs(title = "Selected-period forest residuals", x = "Predicted ridership", y = "Observed minus predicted"))
