# Regression, tree, k-nearest-neighbor and boosting experiments for Route 1A.
args <- commandArgs(trailingOnly=TRUE)
if (!length(args)) stop("Supply the authorized off-campus workbook.")
workbook <- args[1]
library(readxl)
library(caret)
source("src/time_segments.R")
d <- if(grepl("[.]csv$",workbook,ignore.case=TRUE)) read.csv(workbook,check.names=FALSE) else read_xlsx(workbook,sheet=2,col_names=TRUE)
d <- as.data.frame(d)
d$WorkDate <- as.Date(d$WorkDate)
dim(d)

# Handling missing data
mean_ridership1 = mean(d$`1A`, na.rm = T)
mean_ridership2 = mean(d$`2B`, na.rm = T)
mean_ridership3 = mean(d$`6A`, na.rm = T)
mean_ridership4 = mean(d$`6B`, na.rm = T)


d$`1A` = ifelse(is.na(d$`1A`), 
                mean_ridership1, d$`1A`)
d$`2B` = ifelse(is.na(d$`2B`), 
                mean_ridership2, d$`2B`)
d$`6A` = ifelse(is.na(d$`6A`), 
                mean_ridership3, d$`6A`)
d$`6B` = ifelse(is.na(d$`6B`), 
                mean_ridership4, d$`6B`)

cor(d[2:ncol(d)])

## 1A: September 1-30, 2023 (29 observations in the supplied table).
d3_1 <- select_citybus_segment(d, "exploratory")[, c(2, 6:ncol(d)), drop = FALSE]


### Split dataset into training and test set
train <- d3_1[1:20, ]
test <- d3_1[21:29, ]

### Select variables through variable selection
library(leaps)
mlrB <- regsubsets(`1A` ~ ., data = d3_1,
                   
                   , nbest = 1
                   , intercept = T       # should model have intercept term (B0)?
                   , method = "backward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL        # NULL for no limit on number of variables
)
summary(mlrB)$which[which.max(summary(mlrB)$adjr2),]

### Train & Test Multiple Linear Regression
# MLR on sequential training and test set
model1 <- lm(`1A` ~ tempmax+temp+feelslikemax+feelslikemin+feelslike+dew+precip+precipcover+sealevelpressure+cloudcover+uvindex+
               severerisk, data=train)
summary(model1) # R-squared train: 96.94
pred <- predict(model1, newdata = train)
rmse <- sqrt(mean((pred - train$`1A`)^2))
print(rmse)
## Evaluate model 1 on test set:
rf_preds <- predict(model1, newdata = test)
# Actual values
actual <- test$`1A`
# Calculate R-squared
(rsq <- 1 - sum((rf_preds - actual)^2) / sum((actual - mean(actual))^2))

# Calculate RMSE
(rmse <- sqrt(mean((rf_preds - actual)^2)))


### Method 2 of splitting: Randomly split
set.seed(1234) # set a seed so you can replicate your results
library(caret)

# identify records that will be used in the training set. Here we are doing a
inTrain <- createDataPartition(y = d3_1$`1A`,   # outcome variable
                               p = .70,   # % of training data you want
                               list = F)
# create your partitions
train_d <- d3_1[inTrain,]  # training data set
test_d <- d3_1[-inTrain,]  # test data set

# MLR on ramdom split of train and test sets: 
model1.1 <- lm(`1A` ~ tempmax+temp+feelslikemax+feelslikemin+feelslike+dew+precip+precipcover+sealevelpressure+cloudcover+uvindex+
               severerisk, data=train_d)
summary(model1.1) # R-squared train: 85.71
pred <- predict(model1.1, newdata = train_d)
rmse <- sqrt(mean((pred - train_d$`1A`)^2))
print(rmse)
## Evaluate model 1 on test set:
rf_preds <- predict(model1.1, newdata = test_d)
# Actual values
actual <- test_d$`1A`
# Calculate R-squared
(rsq <- 1 - sum((rf_preds - actual)^2) / sum((actual - mean(actual))^2))

# Calculate RMSE
(rmse <- sqrt(mean((rf_preds - actual)^2)))

### Model type 2: XGBoost
ctrl <- trainControl(method = "none",
                     classProbs = FALSE,
                     summaryFunction = defaultSummary,
                     allowParallel = TRUE)

# Manually specify the model hyperparameters
xgb_grid <- expand.grid(
  nrounds = 100,
  max_depth = 6,
  eta = 0.3,
  gamma = 0,
  colsample_bytree = 1,
  min_child_weight = 1,
  subsample = 1
)

# Train the model
model2 <- train(`1A` ~ tempmax + temp + feelslikemax + feelslikemin + feelslike +
                  dew + precip + precipcover + sealevelpressure + cloudcover +
                  uvindex + severerisk,
                data = train_d,
                method = "xgbTree",
                trControl = ctrl,
                metric = "RMSE",
                tuneGrid = xgb_grid)
model2$results
model2$bestTune
best_result <- model2$results[
  apply(model2$results[, names(model2$bestTune)], 1, function(x) all(x == model2$bestTune)),
]
best_result
model2
# Predict on training data
pred_train <- predict(model2, newdata = train_d)

# Calculate R-squared and RMSE
(r_squared <- cor(pred_train, train_d$`1A`)^2)
(rmse <- sqrt(mean((pred_train - train_d$`1A`)^2)))
## Evaluate model 1 on test set:
rf_preds <- predict(model2, newdata = test_d)
# Actual values
actual <- test_d$`1A`
# Calculate R-squared
(rsq <- 1 - sum((rf_preds - actual)^2) / sum((actual - mean(actual))^2))

# Calculate RMSE
(rmse <- sqrt(mean((rf_preds - actual)^2)))

### knn
library(caret)

# Train control with no resampling
ctrl <- trainControl(method = "none",
                     classProbs = FALSE,
                     summaryFunction = defaultSummary,
                     allowParallel = TRUE)

# Manually specify the number of neighbors (k)
knn_grid <- expand.grid(k = 5)  # choose any k you want (e.g., 5)

# Train the model
model3 <- train(`1A` ~ tempmax + temp + feelslikemax + feelslikemin + feelslike +
                  dew + precip + precipcover + sealevelpressure + cloudcover +
                  uvindex + severerisk,
                data = train_d,
                method = "knn",
                trControl = ctrl,
                metric = "RMSE",
                tuneGrid = knn_grid)

# Predict and evaluate on training data
pred_knn <- predict(model3, newdata = train_d)
(r_squared_knn <- cor(pred_knn, train_d$`1A`)^2) # R-squared train: 14.17
(rmse_knn <- sqrt(mean((pred_knn - train_d$`1A`)^2))) # RMSE: 169.49
## Evaluate model 1 on test set:
rf_preds <- predict(model3, newdata = test_d)
# Actual values
actual <- test_d$`1A`
# Calculate R-squared
(rsq <- 1 - sum((rf_preds - actual)^2) / sum((actual - mean(actual))^2))

# Calculate RMSE
(rmse <- sqrt(mean((rf_preds - actual)^2)))

### Decision Tree
# Load required package
library(rpart)
library(rpart.plot)  # For nice tree plots

# Fit the regression tree model
tree_model <- rpart(`1A` ~ tempmax + temp + feelslikemax + feelslikemin + feelslike +
                      dew + precip + precipcover + sealevelpressure + cloudcover +
                      uvindex + severerisk,
                    data = train_d,
                    method = "anova")  # 'anova' for regression

# Print the model summary
summary(tree_model)

# Plot the tree
rpart.plot(tree_model)

# Predict on training data
pred_tree <- predict(tree_model, newdata = train_d)

# R-squared and RMSE
(r_squared_tree <- cor(pred_tree, train_d$`1A`)^2) # R-squared train: 20.73
(rmse_tree <- sqrt(mean((pred_tree - train_d$`1A`)^2)))
## Evaluate model 1 on test set:
rf_preds <- predict(tree_model, newdata = test_d)
# Actual values
actual <- test_d$`1A`
# Calculate R-squared
(rsq <- 1 - sum((rf_preds - actual)^2) / sum((actual - mean(actual))^2))

# Calculate RMSE
(rmse <- sqrt(mean((rf_preds - actual)^2)))

### Random Forest
library(randomForest)

# Set training control to no resampling
ctrl <- trainControl(method = "none",
                     classProbs = FALSE,
                     summaryFunction = defaultSummary,
                     allowParallel = TRUE)

# Set the number of variables randomly sampled as candidates at each split (mtry)
tune_grid <- expand.grid(mtry = 3)  # You can change this value

# Train the random forest model (no CV)
model7 <- train(`1A` ~ tempmax + temp + feelslikemax + feelslikemin + feelslike + 
                  dew + precip + precipcover + sealevelpressure + cloudcover + 
                  uvindex + severerisk,
                data = train_d,
                method = "rf",
                trControl = ctrl,
                tuneGrid = tune_grid,
                metric = "RMSE")
# Predict on training data
pred_tree <- predict(model7, newdata = train_d)

# R-squared and RMSE
(r_squared_tree <- cor(pred_tree, train_d$`1A`)^2) # R-squared train: 93.12
(rmse_tree <- sqrt(mean((pred_tree - train_d$`1A`)^2)))
## Evaluate model 1 on test set:
rf_preds <- predict(model7, newdata = test_d)
# Actual values
actual <- test_d$`1A`
# Calculate R-squared
(rsq <- 1 - sum((rf_preds - actual)^2) / sum((actual - mean(actual))^2))

# Calculate RMSE
(rmse <- sqrt(mean((rf_preds - actual)^2)))


#### July 1-November 30, 2023: July, August, September and November
# are present in the supplied table (119 observations; October is absent).
d4_1 <- select_citybus_segment(d, "comparison")[, c(2, 6:ncol(d)), drop = FALSE]


set.seed(1234) # set a seed so you can replicate your results

# identify records that will be used in the training set. Here we are doing a
inTrain <- createDataPartition(y = d4_1$`1A`,   # outcome variable
                               p = .80,   # % of training data you want
                               list = F)
# create your partitions
train_d <- d4_1[inTrain,]  # training data set
test_d <- d4_1[-inTrain,]  # test data set

# Select variables on train set
mlrB <- regsubsets(`1A` ~ ., data = train_d,
                   
                   , nbest = 1
                   , intercept = T       # should model have intercept term (B0)?
                   , method = "backward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL        # NULL for no limit on number of variables
)
summary(mlrB)$which[which.max(summary(mlrB)$adjr2),]

# MLR
model1 <- lm(`1A` ~ tempmax+tempmin+temp+dew+humidity+snowdepth+windgust+windspeed+solarradiation+solarenergy+uvindex,
             data = train_d)
summary(model1)  # R-squared train: 23.32
## Evaluate model 1 on test set:
rf_preds <- predict(model1, newdata = test_d)
# Actual values
actual <- test_d$`1A`
# Calculate R-squared
(rsq <- 1 - sum((rf_preds - actual)^2) / sum((actual - mean(actual))^2))

# Calculate RMSE
(rmse <- sqrt(mean((rf_preds - actual)^2)))

### Decision Tree
# Load required package

# Fit the regression tree model
tree_model <- rpart(`1A` ~ tempmax+tempmin+temp+dew+humidity+snowdepth+windgust+windspeed+solarradiation+solarenergy+uvindex,
                    data = train_d,
                    method = "anova")  # 'anova' for regression

# Print the model summary
summary(tree_model)

# Plot the tree
rpart.plot(tree_model)
# Predict on training data
pred_tree <- predict(tree_model, newdata = train_d)

# R-squared and RMSE
(r_squared_tree <- cor(pred_tree, train_d$`1A`)^2)
(rmse_tree <- sqrt(mean((pred_tree - train_d$`1A`)^2))) #147.94

rf_preds <- predict(tree_model, newdata = test_d)
# Actual values
actual <- test_d$`1A`
# Calculate R-squared
(rsq <- 1 - sum((rf_preds - actual)^2) / sum((actual - mean(actual))^2))

# Calculate RMSE
(rmse <- sqrt(mean((rf_preds - actual)^2)))


### Train and Test sequentially split
train <- d4_1[1:95, ]
test <- d4_1[96:nrow(d4_1), ]

tree_model <- rpart(`1A` ~ .,
                    data = train,
                    method = "anova")  # 'anova' for regression
# Print the model summary
summary(tree_model)

# Plot the tree
rpart.plot(tree_model)
# Predict on training data
pred_tree <- predict(tree_model, newdata = train)

# R-squared and RMSE
(r_squared_tree <- cor(pred_tree, train$`1A`)^2)
(rmse_tree <- sqrt(mean((pred_tree - train$`1A`)^2))) #147.94

rf_preds <- predict(tree_model, newdata = test)
# Actual values
actual <- test$`1A`
# Calculate R-squared
(rsq <- 1 - sum((rf_preds - actual)^2) / sum((actual - mean(actual))^2))

# Calculate RMSE
(rmse <- sqrt(mean((rf_preds - actual)^2)))

### Multiple Linear Regression
model_1 <- lm(`1A` ~ ., data = train)
summary(model_1)

library(ggplot2)

# Generate predictions from the model
pred_lm <- predict(model_1, newdata = test)

# Create a data frame to plot
plot_df <- data.frame(
  Actual = test$`1A`,
  Predicted = pred_lm
)

# Plot predicted vs actual
ggplot(plot_df, aes(x = Actual, y = Predicted)) +
  geom_point(color = "#1f77b4", size = 2) +  # blue points
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "red") +  # ideal line
  labs(
    title = "Linear Regression: Predicted vs. Actual",
    x = "Actual Values",
    y = "Predicted Values"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold"),
    axis.title = element_text(face = "bold")
  )

pred_tree <- predict(model_1, newdata = train)
# R-squared and RMSE
(r_squared_tree <- cor(pred_tree, train$`1A`)^2)
(rmse_tree <- sqrt(mean((pred_tree - train$`1A`)^2))) #164.4973

rf_preds <- predict(model_1, newdata = test)
# Actual values
actual <- test$`1A`
# Calculate R-squared
(rsq <- 1 - sum((rf_preds - actual)^2) / sum((actual - mean(actual))^2))

# Calculate RMSE
(rmse <- sqrt(mean((rf_preds - actual)^2))) # RMSE test: 162.3368

### XGBoost on the sequential partition
model2 <- train(`1A` ~ .,
                data = train,
                method = "xgbTree",
                trControl = ctrl,
                metric = "RMSE",
                tuneGrid = xgb_grid)
model2$results
model2$bestTune
best_result <- model2$results[
  apply(model2$results[, names(model2$bestTune)], 1, function(x) all(x == model2$bestTune)),
]
best_result
model2
# Predict on training data
pred_train <- predict(model2, newdata = train)

# Calculate R-squared and RMSE
(r_squared <- cor(pred_train, train$`1A`)^2)
(rmse <- sqrt(mean((pred_train - train$`1A`)^2)))
## Evaluate model 1 on test set:
rf_preds <- predict(model2, newdata = test)
# Actual values
actual <- test$`1A`
# Calculate R-squared
(rsq <- 1 - sum((rf_preds - actual)^2) / sum((actual - mean(actual))^2))

# Calculate RMSE
(rmse <- sqrt(mean((rf_preds - actual)^2)))


### Random Forest
# Set training control to no resampling
ctrl <- trainControl(method = "none",
                     classProbs = FALSE,
                     summaryFunction = defaultSummary,
                     allowParallel = TRUE)

# Set the number of variables randomly sampled as candidates at each split (mtry)
tune_grid <- expand.grid(mtry = 3)  # You can change this value

# Train the random forest model (no CV)
model7 <- train(`1A` ~ .,
                data = train,
                method = "rf",
                trControl = ctrl,
                tuneGrid = tune_grid,
                metric = "RMSE")
# Predict on training data
pred_tree <- predict(model7, newdata = train)

# R-squared and RMSE
(r_squared_tree <- cor(pred_tree, train$`1A`)^2) # R-squared train: 95.54
(rmse_tree <- sqrt(mean((pred_tree - train$`1A`)^2)))
## Evaluate model 1 on test set:
rf_preds <- predict(model7, newdata = test)
# Actual values
actual <- test$`1A`
# Calculate R-squared
(rsq <- 1 - sum((rf_preds - actual)^2) / sum((actual - mean(actual))^2))

# Calculate RMSE
(rmse <- sqrt(mean((rf_preds - actual)^2)))


varImpPlot(model7$finalModel, main = "Variable Importance (Random Forest)")
library(ggplot2)

ggplot(data = NULL, aes(x = actual, y = rf_preds)) +
  geom_point(color = "blue", size = 2) +
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +
  labs(x = "Actual Values", y = "Predicted Values",
       title = "Random Forest: Predicted vs. Actual") +
  theme_minimal()

library(ggplot2)

ggplot(data = NULL, aes(x = actual, y = rf_preds)) +
  geom_point(color = "#1f77b4", size = 3, alpha = 0.8) +  # Nicer blue, slightly transparent
  geom_abline(slope = 1, intercept = 0, color = "darkred", linetype = "dashed", linewidth = 1) +  # More elegant line
  labs(
    x = "Actual Values",
    y = "Predicted Values",
    title = "Random Forest Regression: Predicted vs. Actual",
    subtitle = "Ideal predictions lie along the dashed line",
    caption = "Source: Random Forest Model Output"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 12, color = "gray30"),
    axis.title = element_text(face = "bold"),
    panel.grid.major = element_line(color = "gray90"),
    panel.grid.minor = element_blank()
  ) +
  coord_equal()  # Ensures x and y are on the same scale

### Regression node-impurity importance
importance_df <- as.data.frame(randomForest::importance(model7$finalModel, type = 2))  # extract the underlying randomForest model from the caret wrapper
importance_df$Variable <- rownames(importance_df)
















write.csv(data.frame(model="Random Forest",evaluation="chronological test",n_train=nrow(train),n_test=nrow(test),r_squared=rsq,rmse=rmse),"model-experiment-metrics.csv",row.names=FALSE)
