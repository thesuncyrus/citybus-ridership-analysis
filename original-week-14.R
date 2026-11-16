library(readxl)
library(caret)
d <- read_xlsx("Off Campus routes.xlsx", sheet=2, col_names = TRUE)
d <- as.data.frame(d)
d$WorkDate <- as.Date(d$WorkDate)
dim(d)
str(d)
View(d)

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

str(d)
cor(d[2:ncol(d)])

## 1A: Sep - Nov
d3_1 <- d[240:268, c(2, 6:ncol(d))]
head(d3_1)

str(d3_1)

### 1A: 
d4_1 <- d[179:209, c(2, 6:ncol(d))]
View(d4_1)

### Multiple linear regression
library(leaps)
mlrB <- regsubsets(`1A` ~ ., data = d3_1,
                   
                   , nbest = 1           # 1 best model for each number of predictors
                   , intercept = T       # should model have intercept term (B0)?
                   , method = "backward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL        # NULL for no limit on number of variables
)
summary(mlrB)$which[which.max(summary(mlrB)$adjr2),]

# Normal (no crossvalidation: R-squared: 77.3, RMSE: 80.39)
model1 <- lm(`1A` ~ tempmax+temp+feelslikemax+feelslikemin+feelslike+dew+precip+precipcover+sealevelpressure+cloudcover+uvindex+
               severerisk, data=d3_1)
summary(model1)
# 1. Predict values
pred <- predict(model1, newdata = d3_1)
# 2. Calculate RMSE
rmse <- sqrt(mean((pred - d3_1$`1A`)^2))
print(rmse) # 80.39192

## Evaluate model 1 on test set:
rf_preds <- predict(model1, newdata = d4_1)
# Actual values
actual <- d4_1$`1A`

# Calculate R-squared
(rsq <- 1 - sum((rf_preds - actual)^2) / sum((actual - mean(actual))^2))

# Calculate RMSE
(rmse <- sqrt(mean((rf_preds - actual)^2)))




# MLR 3-fold: R-squared: 41.5%, RMSE: 363.08
set.seed(123)
ctrl <- trainControl(method="cv",     # cross-validation set approach to use
                     number=3,        # k number of times to do k-fold
                     classProbs = F,  # if you want probabilities
                     #summaryFunction = twoClassSummary, # for classification
                     summaryFunction = defaultSummary,  # for regression
                     allowParallel=T)
model1.1 <- train(`1A` ~ tempmax+temp+feelslikemax+feelslikemin+feelslike+dew+precip+precipcover+sealevelpressure+cloudcover+uvindex+
                  severerisk,               # model specification
                data = d3_1,        # train set used to build model
                method = "lm",      # type of model you want to build
                trControl = ctrl,    # how you want to learn
                metric = "RMSE"       # performance measure
)
model1.1

## Evaluate model 1 on test set:
rf_preds <- predict(model1.1, newdata = d4_1)
# Actual values
actual <- d4_1$`1A`

# Calculate R-squared
(rsq <- 1 - sum((rf_preds - actual)^2) / sum((actual - mean(actual))^2))

# Calculate RMSE
(rmse <- sqrt(mean((rf_preds - actual)^2)))

### XG Boost: 3-fold (R-squared: 15.9%, RMSE: 210.77)
ctrl <- trainControl(method="cv",     # cross-validation set approach to use
                     number=3,        # k number of times to do k-fold
                     classProbs = F,  # if you want probabilities
                     #summaryFunction = twoClassSummary, # for classification
                     summaryFunction = defaultSummary,  # for regression
                     allowParallel=T)
model2 <- train(`1A` ~ tempmax+temp+feelslikemax+feelslikemin+feelslike+dew+precip+precipcover+sealevelpressure+cloudcover+uvindex+
                  severerisk,               # model specification
                  data = d3_1,        # train set used to build model
                  method = "xgbTree",      # type of model you want to build
                  trControl = ctrl,    # how you want to learn
                  metric = "RMSE"       # performance measure
)
model2$results
model2$bestTune
best_result <- model2$results[
  apply(model2$results[, names(model2$bestTune)], 1, function(x) all(x == model2$bestTune)),
]
best_result
model2

## Evaluate model 2 on test set:
rf_preds <- predict(model2, newdata = d4_1)
# Actual values
actual <- d4_1$`1A`

# Calculate R-squared
(rsq <- 1 - sum((rf_preds - actual)^2) / sum((actual - mean(actual))^2))

# Calculate RMSE
(rmse <- sqrt(mean((rf_preds - actual)^2)))

library(xgboost)
library(Ckmeans.1d.dp)  # Needed for plotting

# Extract the final xgboost model from caret object
xgb_model <- model2$finalModel

# Compute feature importance (Gain = how much each feature improves the model)
importance_matrix <- xgb.importance(model = xgb_model)

# Plot the top 10 most important features (by Gain)
xgb.plot.importance(importance_matrix, 
                    top_n = 10, 
                    rel_to_first = TRUE, 
                    xlab = "Feature Importance (XG Boost)")

### knn: 3-fold (R-squared: 33%, RMSE: 183.82)
ctrl <- trainControl(method="cv",     # cross-validation set approach to use
                     number=3,        # k number of times to do k-fold
                     classProbs = F,  # if you want probabilities
                     #summaryFunction = twoClassSummary, # for classification
                     summaryFunction = defaultSummary,  # for regression
                     allowParallel=T)
model3 <- train(`1A` ~ tempmax+temp+feelslikemax+feelslikemin+feelslike+dew+precip+precipcover+sealevelpressure+cloudcover+uvindex+
                  severerisk,               # model specification
                data = d3_1,        # train set used to build model
                method = "knn",      # type of model you want to build
                trControl = ctrl,    # how you want to learn
                metric = "RMSE"       # performance measure
)
summary(model3)
model3$bestTune  # Best value of k (number of neighbors)
best_result <- model3$results[
  model3$results$k == model3$bestTune$k, 
]
best_result
model3

#### Decision Tree:
library(tree)
tree.ridership = tree(`1A` ~tempmax+temp+feelslikemax+feelslikemin+feelslike+dew+precip+precipcover+sealevelpressure+cloudcover+uvindex+
                        severerisk
                   , data = d3_1
                   )
summary(tree.ridership)

## Evaluate model 2 on test set:
rf_preds <- predict(tree.ridership, newdata = d4_1)
# Actual values
actual <- d4_1$`1A`

# Calculate R-squared
(rsq <- 1 - sum((rf_preds - actual)^2) / sum((actual - mean(actual))^2))

# Calculate RMSE
(rmse <- sqrt(mean((rf_preds - actual)^2)))
# plot the tree
plot(tree.ridership); text(tree.ridership,pretty=0)
# perform cross-validation
cv.ridership = cv.tree(tree.ridership)
plot(cv.ridership$size
     , cv.ridership$dev
     , type = 'b')
# prune the tree
class(prune.ridership)

prune.ridership = prune.tree(tree.ridership, best=2)
plot(prune.ridership); text(prune.ridership,pretty=0)

# Assuming you have a test set 'test_data' with the actual '1A' values
predicted_values <- predict(prune.ridership, newdata = d3_1)

# Calculate R-squared: 
actual_values <- d3_1$`1A`
rsq <- 1 - sum((predicted_values - actual_values)^2) / sum((actual_values - mean(actual_values))^2)
print(rsq) # 0.2118315

rmse <- sqrt(mean((predicted_values - actual_values)^2))
print(rmse) # 149.7945

### Decision tree: ChatGPT version: No prune: R-squared: 0.241548053229649
# Fit the decision tree model
tree.ridership <- tree(`1A` ~ tempmax + temp + feelslikemax + feelslikemin + feelslike + dew + precip + precipcover + sealevelpressure + cloudcover + uvindex + severerisk, data = d3_1)
# Prune the tree (choose a suitable 'best' parameter)
summary(tree.ridership)  # This will give you the number of nodes and splits
# Plot the pruned tree
plot(prune.ridership)
text(prune.ridership, pretty = 0)

predicted_values <- predict(prune.ridership, newdata = d3_1)
actual_values <- d3_1$`1A`
rsq <- 1 - sum((predicted_values - actual_values)^2) / sum((actual_values - mean(actual_values))^2)
print(paste("R-squared: ", rsq))

### Neural Network: definitely not it
ctrl <- trainControl(method="cv",     # cross-validation set approach to use
                     number=3,        # k number of times to do k-fold
                     classProbs = F,  # if you want probabilities
                     #summaryFunction = twoClassSummary, # for classification
                     summaryFunction = defaultSummary,  # for regression
                     allowParallel=T)
model6 <- train(`1A` ~ tempmax+temp+feelslikemax+feelslikemin+feelslike+dew+precip+precipcover+sealevelpressure+cloudcover+uvindex+
                  severerisk,               # model specification
                data = d3_1,        # train set used to build model
                method = "nnet",      # type of model you want to build
                trControl = ctrl,    # how you want to learn
                metric = "RMSE"       # performance measure
)
model6

### Random forest: R-squared: 41.1%, RMSE: 175.10
# Define the hyperparameter grid for tuning
tune_grid <- expand.grid(
  mtry = c(2, 3, 4, 5, 6)  # Example of mtry values to try
)

# Train the random forest model with tuning
ctrl <- trainControl(method = "cv",     # cross-validation set approach to use
                     number = 3,        # k number of times to do k-fold
                     classProbs = F,    # if you want probabilities
                     summaryFunction = defaultSummary,  # for regression
                     allowParallel = T)

model7 <- train(`1A` ~ tempmax + temp + feelslikemax + feelslikemin + feelslike + dew + precip + precipcover + sealevelpressure + 
                  cloudcover + uvindex + severerisk,  # model specification
                data = d3_1,  # train set used to build model
                method = "rf",  # random forest model
                trControl = ctrl,  # control settings for learning
                tuneGrid = tune_grid,  # grid of hyperparameters for tuning
                metric = "RMSE")  # performance measure

# Print the model results
model7

## Evaluate model 2 on test set:
rf_preds <- predict(model7, newdata = d4_1)
# Actual values
actual <- d4_1$`1A`

# Calculate R-squared
(rsq <- 1 - sum((rf_preds - actual)^2) / sum((actual - mean(actual))^2))

# Calculate RMSE
(rmse <- sqrt(mean((rf_preds - actual)^2)))


# Load libraries
#library(randomForest)
library(ggplot2)

# Extract feature importance
importance_vals <- varImp(model7, scale = TRUE)

# View the importance table
print(importance_vals)

# Plot the importance
plot(importance_vals, main = "Feature Importance (Gini) - Random Forest")


# Convert to a data frame
importance_df <- as.data.frame(importance_vals$importance)
importance_df$Feature <- rownames(importance_df)

# Plot using ggplot2
ggplot(importance_df, aes(x = reorder(Feature, Overall), y = Overall)) +
  geom_col(fill = "#0073C2FF") +
  coord_flip() +
  labs(title = "Feature Importance (Gini Index) - Random Forest",
       x = "Feature", y = "Importance (Gini-based)") +
  theme_minimal()




