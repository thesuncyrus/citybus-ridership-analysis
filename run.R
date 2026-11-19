# Model comparison within specified observation periods.
# Rscript run.R workbook.xlsx outputs [report_months|source_rows]
# Reported scores are never used in fitting, tuning or evaluation.
source("functions.R"); source("prepare.R")
for (pkg in c("caret", "randomForest", "rpart"))
  if (!requireNamespace(pkg, quietly = TRUE)) stop(paste("Install", pkg))
args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("Usage: Rscript run.R workbook.xlsx [output-directory] [period]")
out <- if (length(args) > 1) args[2] else "outputs"
period <- if (length(args) > 2) args[3] else "source_rows"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
d <- read_citybus(args[1])
split <- chronological_split(select_period(d, period))
stopifnot(!length(intersect(split$train$WorkDate, split$test$WorkDate)))
metrics <- predictions <- importances <- list(); models <- list()
for (route in citybus_config$routes) {
  tr <- split$train[is.finite(split$train[[route]]), , drop = FALSE]
  te <- split$test[is.finite(split$test[[route]]), , drop = FALSE]
  if (nrow(tr) < 20 || nrow(te) < 2) stop("Insufficient observed route outcomes.")
  # All 24 source weather fields; the workbook has no missing weather.
  # Missing route outcomes are excluded, never synthesized for scoring.
  x <- tr[weather_features]; xt <- te[weather_features]
  stopifnot(!anyNA(x), !anyNA(xt))
  train <- data.frame(y = tr[[route]], x, check.names = FALSE)
  test <- data.frame(y = te[[route]], xt, check.names = FALSE)
  linear <- lm(y ~ ., data = train)
  set.seed(citybus_config$chronological$seed)
  tree <- rpart::rpart(y ~ ., data = train, method = "anova")
  set.seed(citybus_config$chronological$seed)
  forest <- caret::train(y ~ ., data = train, method = "rf",
    trControl = caret::trainControl(method = "none", allowParallel = FALSE),
    tuneGrid = data.frame(mtry = citybus_config$chronological$mtry), ntree = citybus_config$chronological$ntree, metric = "RMSE")
  models[[route]] <- list(linear = linear, tree = tree, forest = forest)
  for (partition in c("train", "test")) {
    target <- if (partition == "train") train else test
    dates <- if (partition == "train") tr$WorkDate else te$WorkDate
    estimates <- list("Training mean" = rep(mean(train$y), nrow(target)))
    # Preserve source lm behavior for aliases; separately count non-estimable rows.
    estimable <- predict(linear, newdata = target, rankdeficient = "NA")
    estimates[["Linear regression"]] <- predict(linear, newdata = target, rankdeficient = "simple")
    estimates[["Decision tree"]] <- predict(tree, newdata = target)
    estimates[["Random forest"]] <- predict(forest, newdata = target)
    for (method in names(estimates)) {
      pred <- as.numeric(estimates[[method]])
      m <- regression_metrics(target$y, pred)
      metrics[[length(metrics) + 1]] <- data.frame(period = period, route = route,
        model = method, partition = partition, n = length(pred),
        r_squared = m["r_squared"], rmse = m["rmse"], mae = m["mae"],
        correlation_squared = if (sd(pred) > 0) cor(pred, target$y)^2 else NA_real_,
        linear_nonestimable = if (method == "Linear regression") sum(is.na(estimable)) else 0,
        first_date = min(dates), last_date = max(dates))
      predictions[[length(predictions) + 1]] <- data.frame(period = period, route = route,
        model = method, partition = partition, date = dates, actual = target$y, predicted = pred)
    }
  }
  imp <- randomForest::importance(forest$finalModel, type = 2)
  importances[[route]] <- data.frame(period = period, route = route,
    feature = rownames(imp), decrease_node_impurity = imp[, 1])
}
write.csv(do.call(rbind, metrics), file.path(out, "recomputed-metrics.csv"), row.names = FALSE)
write.csv(do.call(rbind, predictions), file.path(out, "predictions.csv"), row.names = FALSE)
write.csv(do.call(rbind, importances), file.path(out, "importance.csv"), row.names = FALSE)
saveRDS(models, file.path(out, "models.rds"))
writeLines(c(paste("Period:", period), paste("Workbook MD5:", tools::md5sum(args[1])),
  "Seed 1234 reset before each stochastic model; no score targeting.",
  "R-squared = 1-SSE/SST throughout. cor^2 is a separate field.",
  "R-squared is 1-SSE/SST; squared correlation is reported separately.",
  capture.output(sessionInfo())), file.path(out, "run-info.txt"))
print(subset(do.call(rbind, metrics), route == "1A" & partition == "test"))
