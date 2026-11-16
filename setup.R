packages <- c("readxl", "ggplot2", "caret", "randomForest", "rpart", "svglite", "leaps", "xgboost", "rpart.plot")
missing <- packages[!vapply(packages, requireNamespace, TRUE, quietly = TRUE)]
if (length(missing)) install.packages(missing, repos = "https://cloud.r-project.org")
cat("All CityBus dependencies available.\n")


