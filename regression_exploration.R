# Reproduce the 29-observation fit documented in the poster and report.
# This is in-sample exploration, not a held-out prediction score.
# Rscript regression_exploration.R workbook.xlsx outputs
source("functions.R"); source("prepare.R")
library(ggplot2)
args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("Supply the off-campus workbook.")
out <- if (length(args) > 1) args[2] else "outputs"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
d <- read_citybus(args[1])
small <- d[240:268, ]; small$y <- small[["1A"]]
# Weather predictors for the selected Route 1A regression.
model <- lm(y ~ tempmax + temp + feelslikemax + feelslikemin + feelslike +
  dew + precip + precipcover + sealevelpressure + cloudcover + uvindex + severerisk,
  data = small)
m <- regression_metrics(small$y, fitted(model))
result <- data.frame(stage = "Poster/report selected regression; in-sample",
  n = nrow(small), first_date = min(small$WorkDate), last_date = max(small$WorkDate),
  r_squared = m["r_squared"], adjusted_r_squared = summary(model)$adj.r.squared,
  rmse = m["rmse"])
write.csv(result, file.path(out, "early-regression.csv"), row.names = FALSE)
coef <- as.data.frame(summary(model)$coefficients); coef$term <- rownames(coef)
write.csv(coef, file.path(out, "early-coefficients.csv"), row.names = FALSE)
writeLines(capture.output(summary(model)), file.path(out, "early-model-summary.txt"))
plot <- data.frame(actual = small$y, predicted = fitted(model))
ggsave(file.path(out, "citybus-early-fit.svg"),
  ggplot(plot, aes(actual, predicted)) + geom_point(colour = "#234f60", size = 2.5) +
  geom_abline(slope = 1, intercept = 0, linetype = 2, colour = "#9e623e") +
  coord_equal() + theme_minimal(base_size = 12) +
  labs(title = "The original 29-observation regression",
    subtitle = sprintf("In-sample R-squared = %.6f; September 2023", m["r_squared"]),
    x = "Observed ridership", y = "Fitted ridership",
    caption = "Exploratory fit; not a test-set result."),
  width = 8, height = 5, device = svglite::svglite)
stopifnot(nrow(small) == 29, round(m["r_squared"], 3) == .773)
print(result)
