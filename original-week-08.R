setwd("/Users/nbc_1128/Documents/MGMT 478/Datasets/My data")
getwd()
library(readxl)
library(caret)

# Fit the linear model
model <- lm(`1A` ~ ., data = d)

# Get standardized coefficients
lm.beta(model)

d <- read_xlsx("Off Campus routes.xlsx", sheet=2, col_names = TRUE)
d <- as.data.frame(d)
d$WorkDate <- as.Date(d$WorkDate)
dim(d)
str(d)
View(d)

########################################################################################################
# Data Cleaning 
# Identify Correlated Predictors and remove them
################################################################################
# calculate correlation matrix 
descrCor <-  cor(d[,6:ncol(d)])
highCorr <- sum(abs(descrCor[upper.tri(descrCor)]) > .85)
summary(descrCor[upper.tri(descrCor)])

highlyCorDescr <- findCorrelation(descrCor, cutoff = 0.85)
filteredDescr <- d[,6:ncol(d)][,-highlyCorDescr] # remove those specific columns
descrCor2 <- cor(filteredDescr)                  # calculate a new cor matrix
# summarize those correlations to see if all features are now within our range
summary(descrCor2[upper.tri(descrCor2)])

d <- cbind(d[, 1:5], filteredDescr)
rm(filteredDescr, descrCor, descrCor2, highCorr, highlyCorDescr)  # clean up

str(d)

names(d)
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


# Do analysis on Segment
d2 <- d[179:nrow(d), ]
View(d2)
cor(d2[2:ncol(d2)])

d2 <- d2[, 2:ncol(d2)]


## Model 1: 1A
d2_1 <- d2[, c(1, 5:ncol(d2))]
head(d2_1)
model1 <- lm(`1A` ~ tempmin+humidity+snow, data = d2_1)
summary(model1)

library(leaps)
mlrB <- regsubsets(`1A` ~ ., data = d2_1,
                    
                   , nbest = 1           # 1 best model for each number of predictors
                   , intercept = T       # should model have intercept term (B0)?
                   , method = "backward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL        # NULL for no limit on number of variables
)
summary(mlrB)$which[which.max(summary(mlrB)$adjr2),]


## Model 2: 6A
head(d)
d2_2 <- d[, c(4, 6:ncol(d))]
head(d2_2)
model2 <- lm(`6A` ~ humidity+precip+snow+visibility+uvindex+moonphase, data = d2_2)
summary(model2)

model2.2 <- lm(`6A` ~ ., data = d2_2)
summary(model2.2)
library(leaps)
mlrB <- regsubsets(`6A` ~ ., data = d2_2,
                   
                   , nbest = 1           # 1 best model for each number of predictors
                   , intercept = T       # should model have intercept term (B0)?
                   , method = "backward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL        # NULL for no limit on number of variables
)
summary(mlrB)$which[which.max(summary(mlrB)$adjr2),]


## Model 3: 2B
d3_2 <- d2[, c(2, 5:ncol(d2))]
mlrB <- regsubsets(`2B` ~ ., data = d3_2,
                   
                   , nbest = 1           # 1 best model for each number of predictors
                   , intercept = T       # should model have intercept term (B0)?
                   , method = "backward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL        # NULL for no limit on number of variables
)
summary(mlrB)$which[which.max(summary(mlrB)$adjr2),]
model3 <- lm(`2B` ~ precip+sealevelpressure, data = d3_2)
summary(model3)

## Model 4: 6B
d4_2 <- d2[, c(4, 5:ncol(d2))]
mlrB <- regsubsets(`6B` ~ ., data = d4_2,
                   
                   , nbest = 1           # 1 best model for each number of predictors
                   , intercept = T       # should model have intercept term (B0)?
                   , method = "backward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL        # NULL for no limit on number of variables
)
summary(mlrB)$which[which.max(summary(mlrB)$adjr2),]
model4 <- lm(`6B` ~ tempmin+precip+precipprob+snow+snowdepth+windspeed+cloudcover+uvindex, data = d4_2)
summary(model4)

# Make predictions using the linear model (model4)
predictions <- predict(model4, newdata = d4_2)
# Basic scatter plot of actual vs predicted values
plot(d4_2$`6B`, d4_2$predictions,
     main = "Actual vs Predicted",
     xlab = "Actual Values", ylab = "Predicted Values",
     col = "blue", pch = 16)
abline(0, 1, col = "red")  # Add a 45-degree line for reference

## Quadratic tempmin 
# Add a new column to represent the square of tempmin
d4_2$tempmin_squared <- d4_2$tempmin^2

# Fit the linear regression model with the quadratic term for tempmin
model5_quad <- lm(`6B` ~ tempmin_squared + precip + precipprob + snow + snowdepth + windspeed + cloudcover + uvindex, data = d4_2)

# Summary of the new model
summary(model5_quad)





















# Do analysis on Segment
d3 <- d[59:148, 2:ncol(d)]
View(d3)
cor(d3)




## Model 1: 1A
d3_1 <- d3[, c(1, 5:ncol(d3))]
head(d3_1)
model1 <- lm(`1A` ~ tempmin+precipprob+snow+cloudcover+severerisk, data = d3_1)
summary(model1)

library(leaps)
mlrB <- regsubsets(`1A` ~ ., data = d3_1,
                   
                   , nbest = 1           # 1 best model for each number of predictors
                   , intercept = T       # should model have intercept term (B0)?
                   , method = "backward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL        # NULL for no limit on number of variables
)
summary(mlrB)$which[which.max(summary(mlrB)$adjr2),]


## Model 2: 6A
d3_2 <- d3[, c(3, 5:ncol(d3))]
head(d3_2)
model2 <- lm(`6A` ~ humidity+precip+precipcover+snow+windspeed+sealevelpressure+visibility+uvindex, data = d3_2)
summary(model2)



mlrB <- regsubsets(`6A` ~ ., data = d3_2,
                   
                   , nbest = 1           # 1 best model for each number of predictors
                   , intercept = T       # should model have intercept term (B0)?
                   , method = "backward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL        # NULL for no limit on number of variables
)
summary(mlrB)$which[which.max(summary(mlrB)$adjr2),]

model2.2 <- lm(`6A` ~ humidity*snow+precip+precipcover+windspeed+sealevelpressure+visibility+uvindex, data = d3_2)
summary(model2.2)

plot(d3_2$humidity, d3_2$`6A`)
plot(d3_2$precip, d3_2$`6A`)
plot(d3_2$snow, d3_2$`6A`)
plot(d3_2$windspeed, d3_2$`6A`)

model2.3 <- lm(`6A` ~ humidity*snow+precip*precipcover+windspeed+sealevelpressure+visibility+uvindex, data = d3_2)
summary(model2.3)

model2.3 <- lm(`6A` ~ humidity*snow+precip*precipcover+windspeed+sealevelpressure+visibility+uvindex, data = d3_2)
summary(model2.3)

model2.4 <- lm(`6A` ~ humidity*snow+precip*precipcover+windspeed+sealevelpressure*visibility+uvindex, data = d3_2)
summary(model2.4)

model2.5 <- lm(`6A` ~ humidity*snow+precip*uvindex+precipcover+windspeed+sealevelpressure*visibility, data = d3_2)
summary(model2.5)

mlrB <- regsubsets(`6A` ~ humidity*snow+precip*uvindex+precipcover+windspeed+sealevelpressure*visibility, data = d3_2,
                   
                   , nbest = 1           # 1 best model for each number of predictors
                   , intercept = T       # should model have intercept term (B0)?
                   , method = "backward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL        # NULL for no limit on number of variables
)
summary(mlrB)$which[which.max(summary(mlrB)$adjr2),]

## Model 3: 2B
d3_3 <- d3[, c(2, 5:ncol(d3))]
mlrB <- regsubsets(`2B` ~ ., data = d3_3,
                   
                   , nbest = 1           # 1 best model for each number of predictors
                   , intercept = T       # should model have intercept term (B0)?
                   , method = "backward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL        # NULL for no limit on number of variables
)
summary(mlrB)$which[which.max(summary(mlrB)$adjr2),]
model3 <- lm(`2B` ~ humidity+precip+precipprob+precipcover+snowdepth+windspeed+uvindex, data = d3_3)
summary(model3)




d4 <- d[90:118, 2:ncol(d)]
d4_1 <- d4[, c(3, 5:ncol(d4))]
mlrB <- regsubsets(`6A` ~ ., data = d4_1,
                   
                   , nbest = 1           # 1 best model for each number of predictors
                   , intercept = T       # should model have intercept term (B0)?
                   , method = "backward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL        # NULL for no limit on number of variables
)
summary(mlrB)$which[which.max(summary(mlrB)$adjr2),]
model4.1 <- lm(`6A` ~ humidity+precip+precipcover+severerisk, data = d4_1)
summary(model4.1)












## Model 4: 6B
d3_4 <- d3[, c(4, 5:ncol(d3))]
mlrB <- regsubsets(`6B` ~ ., data = d3_4,
                   
                   , nbest = 1           # 1 best model for each number of predictors
                   , intercept = T       # should model have intercept term (B0)?
                   , method = "backward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL        # NULL for no limit on number of variables
)
summary(mlrB)$which[which.max(summary(mlrB)$adjr2),]
model4 <- lm(`6B` ~ tempmin+humidity+snowdepth+windspeed+winddir+sealevelpressure+uvindex, data = d3_4)
summary(model4)

# Make predictions using the linear model (model4)
predictions <- predict(model4, newdata = d4_2)
# Basic scatter plot of actual vs predicted values
plot(d4_2$`6B`, d4_2$predictions,
     main = "Actual vs Predicted",
     xlab = "Actual Values", ylab = "Predicted Values",
     col = "blue", pch = 16)
abline(0, 1, col = "red")  # Add a 45-degree line for reference

## Quadratic tempmin 
# Add a new column to represent the square of tempmin
d4_2$tempmin_squared <- d4_2$tempmin^2

# Fit the linear regression model with the quadratic term for tempmin
model5_quad <- lm(`6B` ~ tempmin_squared + precip + precipprob + snow + snowdepth + windspeed + cloudcover + uvindex, data = d4_2)

# Summary of the new model
summary(model5_quad)






### Segmentation on Wednesday
# 6A
d2_3 <- d2_2[59:148, ]
mlrB <- regsubsets(`6A` ~ ., data = d2_3,
                   
                   , nbest = 1           # 1 best model for each number of predictors
                   , intercept = T       # should model have intercept term (B0)?
                   , method = "backward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL        # NULL for no limit on number of variables
)
summary(mlrB)$which[which.max(summary(mlrB)$adjr2),]
model1.1 <- lm(`6A` ~ humidity + precip+precipcover+snow+windspeed+sealevelpressure+uvindex, data=d2_3)
summary(model1.1)


# 6A: 240 - 297: Sep - Nov
d2_4 <- d2_2[240:297, ]
mlrB <- regsubsets(`6A` ~ ., data = d2_4,
                   
                   , nbest = 1           # 1 best model for each number of predictors
                   , intercept = T       # should model have intercept term (B0)?
                   , method = "backward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL        # NULL for no limit on number of variables
)
summary(mlrB)$which[which.max(summary(mlrB)$adjr2),]
model1.2 <- lm(`6A` ~tempmin+temp+feelslike+snow+windspeed+visibility+solarradiation+solarenergy, data=d2_4)
summary(model1.2)


## 6A: May - June: Best R-squared: 66.77 ()
d2_5 <- d2_2[119:149, ]
mlrB <- regsubsets(`6A` ~ ., data = d2_5,
                   
                   , nbest = 1           # 1 best model for each number of predictors
                   , intercept = T       # should model have intercept term (B0)?
                   , method = "backward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL        # NULL for no limit on number of variables
)
summary(mlrB)$which[which.max(summary(mlrB)$adjr2),]

model1.3 <- lm(`6A` ~ tempmax+tempmin+temp+feelslikemax+feelslikemin+dew+humidity+precipprob+precipcover+cloudcover+visibility+uvindex+moonphase, data =d2_5)
summary(model1.3)

mlrB <- regsubsets(`6A` ~ tempmax+tempmin+temp+feelslikemax+feelslikemin+dew+humidity+precipprob+precipcover+cloudcover+visibility+uvindex+moonphase, data = d2_5,
                   
                   , nbest = 1           # 1 best model for each number of predictors
                   , intercept = T       # should model have intercept term (B0)?
                   , method = "forward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL        # NULL for no limit on number of variables
)
summary(mlrB)$which[which.max(summary(mlrB)$adjr2),]

## 1A: Sep - Nov: Rsquared: 77.3 
d3_1 <- d[240:268, c(2, 6:ncol(d))]
head(d3_1)

str(d3_1)

# Identify non-variable features: 
nzv <- nearZeroVar(d3_1, saveMetrics = TRUE)
d3_1 <- d3_1[, c(TRUE,!nzv$zeroVar[2:ncol(d3_1)])]

# Identify correlated predictors and remove them:
library(caret)
descrCor <-  cor(d3_1[,2:ncol(d3_1)])                           # correlation matrix
highCorr <- sum(abs(descrCor[upper.tri(descrCor)]) > .85) # num Xs with cor > t
summary(descrCor[upper.tri(descrCor)])                    # summarize the cors

# which columns in your correlation matrix have a correlation greater than some
# specified absolute cutoff. Find them and remove them
highlyCorDescr <- findCorrelation(descrCor, cutoff = 0.85)

sum(is.na(descrCor))  # Count NA values
colSums(is.na(d3_1))  # Identify columns with missing values


filteredDescr <- d3_1[,2:ncol(d3_1)][,-highlyCorDescr] # remove those specific columns
descrCor2 <- cor(filteredDescr)                  # calculate a new cor matrix
# summarize those correlations to see if all features are now within our range
summary(descrCor2[upper.tri(descrCor2)])

# update dataset by removing those filtered vars that were highly correlated
d3_1 <- cbind(d3_1$`1A`, filteredDescr)
names(d3_1)[1] <- "y"

rm(filteredDescr, descrCor, descrCor2, highCorr, highlyCorDescr)  # clean up

# Identify linear dependencies and remove them:
y <- d3_1$y

# create a column of 1s. This will help identify all the right linear combos
d3_1 <- cbind(rep(1, nrow(d3_1)), d3_1[2:ncol(d3_1)])
names(d3_1)[1] <- "ones"

# identify the columns that are linear combos
comboInfo <- findLinearCombos(d3_1)
comboInfo

# remove columns identified that led to linear combos
d3_1 <- d3_1[, -comboInfo$remove]

# remove the "ones" column in the first column
d3_1 <- d3_1[, c(2:ncol(d3_1))]

# Add the target variable back to our data.frame
d3_1 <- cbind(y, d3_1)

rm(y, comboInfo)  # clean up

# Standardize (and/ normalize) your input features.
################################################################################
# Here we standardize the input features (Xs) using the preProcess() function 
# by performing a min-max normalization (aka "range" in caret).

# Step 1) figures out the means, standard deviations, other parameters, etc. to 
# transform each variable
preProcValues <- preProcess(d3_1[,2:ncol(d3_1)], method = c("center", "scale", "YeoJohnson"))
# Step 2) the predict() function actually does the transformation using the 
# parameters identified in the previous step. Weird that it uses predict() to do 
# this, but it does!
d3_1 <- predict(preProcValues, d3_1)


# Design the experiment
ctrl <- trainControl(method = "LOOCV"
                     , classProbs = FALSE
                     , summaryFunction = defaultSummary)
?trainControl

str(d3_1)

# Build the model
# Train a linear regression model on the training set
myModel1 <- train(y ~ .,               # Model formula
                  data = d3_1_log_filled,        # Training dataset
                  method = "glmnet",       # Linear regression model
                  trControl = ctrl,    # Cross-validation settings
                  metric = "RMSE"      # Performance metric for regression
)

# Print model summary
myModel1

model2 <- lm(y~tempmax+temp+feelslikemin+humidity+precip+winddir+sealevelpressure+cloudcover+uvindex+severerisk+moonphase, data = d3_1_log_filled)
summary(model2)

# Apply log transformation to all numeric columns in the dataset (with a constant added to handle zeros/negatives)
d3_1_log <- d3_1
d3_1_log[] <- lapply(d3_1_log, function(x) if(is.numeric(x)) log(x + 1) else x)

# Example: Compare original vs log-transformed variables using histograms
hist(d3_1$tempmax, main = "Original tempmax", xlab = "tempmax")
hist(d3_1_log$tempmax, main = "Log-transformed tempmax", xlab = "Log(tempmax)")

# Check for missing values in the dataset
sum(is.na(d3_1_log))
# Remove rows with missing values
d3_1_log_clean <- na.omit(d3_1_log)

column_means <- colMeans(d3_1_log, na.rm = TRUE)
d3_1_log_filled <- d3_1_log  # Make a copy of the original dataset
for (col in colnames(d3_1_log_filled)) {
  d3_1_log_filled[[col]][is.na(d3_1_log_filled[[col]])] <- column_means[col]
}




tempmax+temp+feelslikemin+humidity+precip+winddir+sealevelpressure+cloudcover+uvindex+severerisk+moonphase




predictions <- predict(myModel1, newdata = d3_1_log_filled)  # Predicted values
residuals <- d3_1_log_filled$y - predictions  # Residuals

# Calculate IQR for residuals
IQR_residuals <- IQR(residuals)
Q1 <- quantile(residuals, 0.25)
Q3 <- quantile(residuals, 0.75)

# Define outlier thresholds
lower_bound <- Q1 - 1.5 * IQR_residuals
upper_bound <- Q3 + 1.5 * IQR_residuals

# Identify outliers
outliers <- residuals[residuals < lower_bound | residuals > upper_bound]
outliers





library(leaps)
mlrB <- regsubsets(y ~ ., data = d3_1,
                   
                   , nbest = 1           # 1 best model for each number of predictors
                   , intercept = T       # should model have intercept term (B0)?
                   , method = "backward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL        # NULL for no limit on number of variables
)
summary(mlrB)$which[which.max(summary(mlrB)$adjr2),]
model2.1 <- lm(`1A` ~ tempmax+temp+feelslikemax+feelslikemin+feelslike+dew+precip+precipcover+sealevelpressure+cloudcover+uvindex+severerisk, data=d3_1)
summary(model2.1)

library(caret)  # For cross-validation

set.seed(123)  # Ensures reproducibility

# Define 5-Fold Cross-Validation (change to any K)
train_control <- trainControl(method = "cv", number = 5)  

# Train model using K-Fold CV
model_kfold <- train(`1A` ~ tempmax + temp + feelslikemax + feelslikemin + feelslike +
                       dew + precip + precipcover + sealevelpressure + cloudcover +
                       uvindex + severerisk, 
                     data = d3_1, 
                     method = "lm", 
                     trControl = train_control)

# Print results
print(model_kfold)


library(ggplot2)

# Get predictions
predictions <- predict(model2.1, newdata = d3_1)

# Create a data frame for plotting
plot_data <- data.frame(Actual = d3_1$`1A`, Predicted = predictions)

# Plot Actual vs. Predicted
ggplot(plot_data, aes(x = Actual, y = Predicted)) +
  geom_point(color = "blue", size = 3) +  # Scatter plot
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +  # Ideal 1:1 line
  labs(title = "Predicted vs. Actual Values",
       x = "Actual Values",
       y = "Predicted Values") +
  theme_minimal()





predictions <- predict(model2.1, newdata = d)
print(predictions)


# Actual values (from the dataset)
actual_values <- d$`1A`  # or the actual target variable in your test set

# Calculate MAE
mae <- mean(abs(predictions - actual_values))
print(paste("Mean Absolute Error (MAE):", mae))



residuals <- myModel1$finalModel$residuals
head(residuals)
plot(residuals, main = "Residual Plot", ylab = "Residuals")
abline(h = 0, col = "red")

predicted_values <- predict(myModel1, newdata = d3_1_log_filled)
actual_values <- d3_1_log_clean$y  # Assuming "y" is your target variable
residuals <- actual_values - predicted_values
head(residuals)

qqnorm(residuals)
qqline(residuals, col = "red")
hist(residuals)




































