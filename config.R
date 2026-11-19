# Existing settings, separated by experiment. Loading this file does not set RNG state.
citybus_config <- list(
  routes = c("1A", "2B", "6A", "6B"),
  weather_features = c("tempmax", "tempmin", "temp", "feelslikemax", "feelslikemin",
    "feelslike", "dew", "humidity", "precip", "precipprob", "precipcover", "snow",
    "snowdepth", "windgust", "windspeed", "winddir", "sealevelpressure", "cloudcover",
    "visibility", "solarradiation", "solarenergy", "uvindex", "severerisk", "moonphase"),
  periods = list(report_year = "2023", report_months = c(7, 8, 11), source_rows = 179:297),
  chronological = list(train_fraction = 0.8, seed = 1234, mtry = 3, ntree = 500),
  early_regression = list(rows = 240:268,
    formula = y ~ tempmax + temp + feelslikemax + feelslikemin + feelslike +
      dew + precip + precipcover + sealevelpressure + cloudcover + uvindex + severerisk),
  segments = list(
    exploratory = as.Date(c("2023-09-01", "2023-09-30")),
    comparison = as.Date(c("2023-07-01", "2023-11-30")),
    segment_evaluation = as.Date(c("2023-07-01", "2023-08-01"))),
  segment_forest = list(train_segment = "exploratory", test_segment = "segment_evaluation",
    seed = NULL, resampling = "cv", folds = 3, mtry = 2:6,
    formula = `1A` ~ tempmax + temp + feelslikemax + feelslikemin + feelslike + dew +
      precip + precipcover + sealevelpressure + cloudcover + uvindex + severerisk),
  experiments = list(seed = 1234, small_train_rows = 1:20, small_test_rows = 21:29,
    small_train_fraction = .70, comparison_train_fraction = .80,
    comparison_train_rows = 1:95, comparison_test_start = 96,
    resampling = "none", mtry = 3, knn_k = 5,
    xgb_grid = expand.grid(nrounds = 100, max_depth = 6, eta = 0.3, gamma = 0,
      colsample_bytree = 1, min_child_weight = 1, subsample = 1),
    small_formula = `1A` ~ tempmax + temp + feelslikemax + feelslikemin + feelslike +
      dew + precip + precipcover + sealevelpressure + cloudcover + uvindex + severerisk,
    comparison_formula = `1A` ~ tempmax + tempmin + temp + dew + humidity + snowdepth +
      windgust + windspeed + solarradiation + solarenergy + uvindex),
  screening = list(full_correlation_cutoff = .85, segment_correlation_cutoff = .75,
    initial_preprocess = "range", final_preprocess = c("center", "scale", "YeoJohnson"),
    excluded_source_rows = c(242L, 262L),
    log_predictors = c("precipprob", "precipcover", "winddir", "sealevelpressure", "cloudcover", "visibility", "severerisk"),
    initial_predictors = c("precipprob", "precipcover", "sealevelpressure", "visibility", "severerisk"),
    cleaned_predictors = c("precipprob", "precipcover", "winddir", "sealevelpressure", "visibility", "uvindex", "severerisk"),
    final_predictors = c("precipcover", "visibility", "severerisk", "moonphase")),
  variable_selection = list(nbest = 1, intercept = TRUE, method = "backward", nvmax = NULL)
)
# NULL above preserves the segment experiment's existing unseeded behavior.
# All-predictor formulas (~ .), target handling and transformations stay in their scripts.
