setwd("/Users/nbc_1128/Documents/MGMT 478/Datasets/My data")

# Install libraries
#library(readxl)
#library(caret)

d <- read_xlsx("Off Campus routes.xlsx", sheet=2, col_names = TRUE)
head(d, n = 5)
d <- as.data.frame(d)
str(d)
# Choose certain columns to work with, set it into a seperate dataset
df <- d[, c(2:5, 12:ncol(d))]
head(df, n=5)

# Handling missing data
mean_ridership1 = mean(df$`1A`, na.rm = T)
mean_ridership2 = mean(df$`2B`, na.rm = T)
mean_ridership3 = mean(df$`6A`, na.rm = T)
mean_ridership4 = mean(df$`6B`, na.rm = T)


df$`1A` = ifelse(is.na(df$`1A`), 
                mean_ridership1, df$`1A`)
df$`2B` = ifelse(is.na(df$`2B`), 
                mean_ridership2, df$`2B`)
df$`6A` = ifelse(is.na(df$`6A`), 
                mean_ridership3, df$`6A`)
df$`6B` = ifelse(is.na(df$`6B`), 
                mean_ridership4, df$`6B`)

str(df)
cor(df)

################################################################################
# Identify Correlated Predictors and remove them
################################################################################
# If you build a model that has highly correlated independent variables it can
# lead to unstable models because it will tend to weight those more even though
# they might not be that important

# calculate correlation matrix using Pearson's correlation formula
descrCor <-  cor(df[,5:ncol(df)])                           # correlation matrix
highCorr <- sum(abs(descrCor[upper.tri(descrCor)]) > .85) # num Xs with cor > t
summary(descrCor[upper.tri(descrCor)])                    # summarize the cors

# which columns in your correlation matrix have a correlation greater than some
# specified absolute cutoff. Find them and remove them
highlyCorDescr <- findCorrelation(descrCor, cutoff = 0.85)
filteredDescr <- df[,2:ncol(df)][,-highlyCorDescr] # remove those specific columns
descrCor2 <- cor(filteredDescr)                  # calculate a new cor matrix
# summarize those correlations to see if all features are now within our range
summary(descrCor2[upper.tri(descrCor2)])

# update dataset by removing those filtered vars that were highly correlated
df <- cbind(df[, 1:4], filteredDescr)

rm(filteredDescr, descrCor, descrCor2, highCorr, highlyCorDescr)  # clean up
head(df)
str(df)

################################################################################
# Identifying linear dependencies and remove them
################################################################################
# Find if any linear combinations exist and which column combos they are.
# Below I add a vector of 1s at the beginning of the dataset. This helps ensure
# the same features are identified and removed.
library(caret)
# first save response
y <- df[, 1:4]

# create a column of 1s. This will help identify all the right linear combos
df <- cbind(rep(1, nrow(df)), df[5:ncol(df)])
names(df)[1] <- "ones"

# identify the columns that are linear combos
comboInfo <- findLinearCombos(df)
comboInfo

# remove columns identified that led to linear combos
df <- df[, -comboInfo$remove]

# remove the "ones" column in the first column
df <- df[, c(3:ncol(df))]

# Add the target variable back to our data.frame
df <- cbind(y, df)

rm(y, comboInfo)  # clean up

################################################################################
# Remove features with limited variation
################################################################################
# remove features where the values they take on is limited
# here we make sure to keep the target variable and only those input
# features with enough variation
nzv <- nearZeroVar(df, saveMetrics = TRUE)
df <- df[, c(TRUE,!nzv$zeroVar[5:ncol(df)])]

################################################################################
# Standardize (and/ normalize) your input features.
################################################################################
# Here we standardize the input features (Xs) using the preProcess() function 
# by performing a min-max normalization (aka "range" in caret).

# Step 1) figures out the means, standard deviations, other parameters, etc. to 
# transform each variable
preProcValues <- preProcess(df[,5:ncol(df)], method = c("range"))
# Step 2) the predict() function actually does the transformation using the 
# parameters identified in the previous step. Weird that it uses predict() to do 
# this, but it does!
df <- predict(preProcValues, df)

####### Work on prediction for only 1 bus route: 1A
df.1 <- df[, c(1, 5:ncol(df))]
head(df.1)
str(df.1)

set.seed(1234) # set a seed so you can replicate your results
#library(caret)

# identify records that will be used in the training set. Here we are doing a
# 70/30 train-test split. You might modify this.
inTrain <- createDataPartition(y = df.1$`1A`,   # outcome variable
                               p = .70,   # % of training data you want
                               list = F)
# create your partitions
train <- df.1[inTrain,]  # training data set
test <- df.1[-inTrain,]  # test data set

# down-sampled training set
dnTrain <- downSample(x=train[,2:ncol(df.1)], y=train$`1A`)

################################################################################
# Specify cross-validation design
################################################################################
ctrl <- trainControl(method="cv",     # cross-validation set approach to use
                     number=3,        # k number of times to do k-fold
                     classProbs = T,  # if you want probabilities
                     #summaryFunction = twoClassSummary, # for classification
                     summaryFunction = defaultSummary,  # for regression
                     allowParallel=F)

## Train model using knn on train dataset
grid <- expand.grid(k = seq(3, 25, by = 2))  # try odd k values from 3 to 25
myModel.1 <- train(`1A` ~ ., 
                  data = train, 
                  method = "knn", 
                  trControl = ctrl, 
                  metric = "RMSE", 
                  tuneGrid = grid)
myModel.1

(logit1_trc <- predict(myModel.1, newdata=train))
### Make a plot of predicted values: 1A
actual <- train$`1A`
predicted <- logit1_trc
residuals <- actual - predicted

library(Metrics)
mae(actual, predicted)      # Mean Absolute Error
rmse(actual, predicted)     # Root Mean Squared Error
r_squared <- 1 - sum((actual - predicted)^2) / sum((actual - mean(actual))^2)
r_squared

plot(actual, predicted,
     xlab = "Actual",
     ylab = "Predicted",
     main = "Predicted vs Actual",
     pch = 19, col = "gold")
abline(a = 0, b = 1, col = "red", lwd = 2)


### Predict 1A ridership using predictors as weather factors & other routes' ridership
set.seed(1234) # set a seed so you can replicate your results
#library(caret)

# identify records that will be used in the training set. Here we are doing a
# 70/30 train-test split. You might modify this.
inTrain <- createDataPartition(y = df$`1A`,   # outcome variable
                               p = .70,   # % of training data you want
                               list = F)
# create your partitions
train <- df[inTrain,]  # training data set
test <- df[-inTrain,]  # test data set

# down-sampled training set
dnTrain <- downSample(x=train[,2:ncol(df)], y=train$`1A`)
ctrl <- trainControl(method="cv",     # cross-validation set approach to use
                     number=3,        # k number of times to do k-fold
                     classProbs = T,  # if you want probabilities
                     #summaryFunction = twoClassSummary, # for classification
                     summaryFunction = defaultSummary,  # for regression
                     allowParallel=F)
head(train)
## Train model using knn on train dataset
grid <- expand.grid(k = seq(3, 25, by = 2))  # try odd k values from 3 to 25
myModel.2 <- train(`1A` ~ ., 
                   data = train, 
                   method = "knn", 
                   trControl = ctrl, 
                   metric = "RMSE", 
                   tuneGrid = grid)
myModel.2

logit2_trc <- predict(myModel.2, newdata=train)
### Make a plot of predicted values: 1A
actual <- train$`1A`
predicted <- logit2_trc
residuals <- actual - predicted

mae(actual, predicted)      # Mean Absolute Error
rmse(actual, predicted)     # Root Mean Squared Error
r_squared <- 1 - sum((actual - predicted)^2) / sum((actual - mean(actual))^2)
r_squared

plot(actual, predicted,
     xlab = "Actual",
     ylab = "Predicted",
     main = "Predicted vs Actual",
     pch = 19, col = "gold")
abline(a = 0, b = 1, col = "red", lwd = 2)
















