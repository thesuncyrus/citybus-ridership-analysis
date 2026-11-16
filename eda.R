# Descriptive analysis and EDA, consolidated from weekly route and heatmap analyses.
# Rscript eda.R workbook.xlsx outputs
source("functions.R"); source("prepare.R")
if (!requireNamespace("ggplot2", quietly = TRUE)) stop("Install ggplot2.")
library(ggplot2)
args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("Usage: Rscript eda.R workbook.xlsx [output-directory]")
out <- if (length(args) > 1) args[2] else "outputs"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
d <- read_citybus(args[1]); routes <- c("1A", "2B", "6A", "6B")
write.csv(audit_citybus(d), file.path(out, "data-audit.csv"), row.names = FALSE)
coverage <- data.frame(first_date = min(d$WorkDate), last_date = max(d$WorkDate),
  observed_dates = nrow(d), calendar_dates = as.integer(max(d$WorkDate) - min(d$WorkDate)) + 1)
write.csv(coverage, file.path(out, "date-coverage.csv"), row.names = FALSE)
long <- do.call(rbind, lapply(routes, function(r) data.frame(
  date = d$WorkDate, month = as.integer(format(d$WorkDate, "%m")),
  weekday = as.integer(format(d$WorkDate, "%u")), route = r, value = d[[r]])))
summarize <- function(x) {
  v <- x[is.finite(x)]
  if (!length(v)) return(c(observed = 0, missing = length(x), mean = NA, median = NA, sd = NA, p25 = NA, p75 = NA))
  c(observed = length(v), missing = sum(!is.finite(x)), mean = mean(v), median = median(v),
    sd = sd(v), p25 = unname(quantile(v, .25)), p75 = unname(quantile(v, .75)))
}
route_summary <- do.call(rbind, lapply(routes, function(r) data.frame(route = r, t(summarize(d[[r]])))))
write.csv(route_summary, file.path(out, "route-summary.csv"), row.names = FALSE)
group_summary <- function(field) {
  groups <- split(long, interaction(long$route, long[[field]], drop = TRUE))
  do.call(rbind, lapply(groups, function(g) data.frame(route = g$route[1], period = g[[field]][1], t(summarize(g$value)))))
}
monthly <- group_summary("month"); weekly <- group_summary("weekday")
write.csv(monthly, file.path(out, "monthly-summary.csv"), row.names = FALSE)
write.csv(weekly, file.path(out, "weekday-summary.csv"), row.names = FALSE)
theme_set(theme_minimal(base_size = 12) + theme(panel.grid.minor = element_blank(),
  plot.title = element_text(face = "bold"), plot.background = element_rect(fill = "#faf9f6", colour = NA)))
save_plot <- function(name, p, width = 9, height = 5) ggsave(file.path(out, name), p, width = width, height = height, device = svglite::svglite)
cols <- c("1A" = "#234f60", "2B" = "#9e623e", "6A" = "#4c7c69", "6B" = "#82709a")
save_plot("citybus-monthly.svg", ggplot(monthly, aes(period, mean, colour = route)) +
  geom_line(linewidth = .8) + geom_point(size = 2) + scale_colour_manual(values = cols) +
  scale_x_continuous(breaks = 1:12, labels = month.abb) +
  labs(title = "Demand varies across routes and months", x = NULL, y = "Mean daily ridership measure", colour = "Route",
    caption = "Observed records only; missing route outcomes are not zero-filled. Full-year retrospective EDA."))
save_plot("citybus-weekday.svg", ggplot(weekly, aes(period, mean, colour = route)) +
  geom_line(linewidth = .8) + geom_point(size = 2) + scale_colour_manual(values = cols) +
  scale_x_continuous(breaks = 1:7, labels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")) +
  labs(title = "Service-day patterns differ by route", x = NULL, y = "Mean daily ridership measure", colour = "Route",
    caption = "Missing service or reporting days cannot be distinguished from the workbook alone."))
# Restrict correlation exploration to training dates so it cannot drive test selection.
tr <- chronological_split(select_period(d))$train
features <- c("temp", "humidity", "precip", "snow", "windspeed", "winddir", "cloudcover", "visibility")
corr <- do.call(rbind, lapply(routes, function(r) do.call(rbind, lapply(features, function(f) {
  ok <- is.finite(tr[[r]]) & is.finite(tr[[f]])
  value <- if (sum(ok) >= 3 && sd(tr[[r]][ok]) > 0 && sd(tr[[f]][ok]) > 0) cor(tr[[r]][ok], tr[[f]][ok]) else NA_real_
  data.frame(route = r, feature = f, n = sum(ok), correlation = value)
}))))
write.csv(corr, file.path(out, "weather-correlations.csv"), row.names = FALSE)
save_plot("citybus-correlations.svg", ggplot(corr, aes(feature, route, fill = correlation)) +
  geom_tile(colour = "#faf9f6", linewidth = 2) + geom_text(aes(label = sprintf("%.2f", correlation)), size = 4) +
  scale_fill_gradient2(low = "#b56d4c", mid = "#f5f3ed", high = "#568b91", limits = c(-1, 1)) +
  labs(title = "Weather associations: selected-period training dates", x = NULL, y = "Route", fill = "Pearson r",
    caption = "Pairwise-complete observations. Associations do not establish weather effects.") +
  theme(axis.text.x = element_text(angle = 35, hjust = 1)), height = 4)
writeLines(c("Retrospective EDA of supplied workbook; no target imputation or outlier deletion.",
  "Correlations use training dates only. Full-period summaries were not used to select model settings.",
  paste("Input MD5:", tools::md5sum(args[1])), capture.output(sessionInfo())), file.path(out, "eda-run-info.txt"))
print(route_summary)
