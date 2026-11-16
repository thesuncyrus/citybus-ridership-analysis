library(readxl)
d <- read_xlsx("Assigned Routes.xlsx", sheet=1, col_names = TRUE)
head(d)
d <- as.data.frame(d)
d$Date <- as.Date(d$Date)
dim(d)
str(d)

########################################################################################################
# Data Cleaning 
# Identify Correlated Predictors and remove them
################################################################################
# calculate correlation matrix 
View(d)
descrCor <-  cor(d[,7:ncol(d)])
highCorr <- sum(abs(descrCor[upper.tri(descrCor)]) > .85)
summary(descrCor[upper.tri(descrCor)])

highlyCorDescr <- findCorrelation(descrCor, cutoff = 0.85)
filteredDescr <- d[,2:ncol(d)][,-highlyCorDescr] # remove those specific columns
descrCor2 <- cor(filteredDescr)                  # calculate a new cor matrix
# summarize those correlations to see if all features are now within our range
summary(descrCor2[upper.tri(descrCor2)])

d <- cbind(d[, 1:6], filteredDescr)
rm(filteredDescr, descrCor, descrCor2, highCorr, highlyCorDescr)  # clean up

str(d)

################################################################################
# Handling missing data
mean_ridership1 = mean(d$`Lafayette Square`, na.rm = T)
mean_ridership2 = mean(d$`Market Square`, na.rm = T)
mean_ridership3 = mean(d$Northwestern, na.rm = T)
mean_ridership4 = mean(d$Salisbury, na.rm = T)
mean_ridership5 = mean(d$`Union St`, na.rm = T)

d$`Lafayette Square` = ifelse(is.na(d$`Lafayette Square`), 
                              mean_ridership1, d$`Lafayette Square`)
d$`Market Square` = ifelse(is.na(d$`Market Square`), 
                              mean_ridership2, d$`Market Square`)
d$Northwestern = ifelse(is.na(d$Northwestern), 
                              mean_ridership3, d$Northwestern)
d$Salisbury = ifelse(is.na(d$Salisbury), 
                              mean_ridership4, d$Salisbury)
d$`Union St` = ifelse(is.na(d$`Union St`), 
                              mean_ridership5, d$`Union St`)


################################################################################
# Identifying linear dependencies and remove them
################################################################################
library(caret)
View(d)
y <- d[, c(2:6)]
# create a column of 1s. This will help identify all the right linear combos
d <- cbind(rep(1, nrow(d)), d[2:ncol(d)])
names(d)[1] <- "ones"
View(d)
# identify the columns that are linear combos
comboInfo <- findLinearCombos(d)
comboInfo
# remove columns identified that led to linear combos
d <- d[, -comboInfo$remove]
str(d)
# remove the "ones" column in the first column
d <- d[, c(2:ncol(d))]

# Add the target variable back to our data.frame
d <- cbind(y, d)

rm(y, comboInfo)  # clean up

################################################################################
# Remove features with limited variation
################################################################################
# remove features where the values they take on is limited
# here we make sure to keep the target variable and only those input
# features with enough variation
nzv <- nearZeroVar(d, saveMetrics = TRUE)
d <- d[, c(TRUE,!nzv$zeroVar[11:ncol(d)])]

# Standardize (and/ normalize) your input features.
################################################################################
# Here we standardize the input features (Xs) using the preProcess() function 
# by performing a min-max normalization (aka "range" in caret).

# Step 1) figures out the means, standard deviations, other parameters, etc. to 
# transform each variable
preProcValues <- preProcess(d[,11:ncol(d)], method = c("range"))
# Step 2) the predict() function actually does the transformation using the 
# parameters identified in the previous step. Weird that it uses predict() to do 
# this, but it does!
d <- predict(preProcValues, d)

################################################################################
# Data partitioning
################################################################################
set.seed(1234) # set a seed so you can replicate your results

# identify records that will be used in the training set. Here we are doing a
# 80/20 train-test split. You might modify this.
trainIndex <- sample(1:nrow(d), size = 0.80 * nrow(d))

tr <- d[trainIndex, ]
te <- d[-trainIndex, ]
head(tr)

X_train <- tr[, 11:ncol(d)]  # Features (X1 to X5)
Y_train <- tr[, 1:5] # Targets (Y1 to Y5)

X_test <- te[, 11:ncol(d)]
Y_test <- te[, 11:ncol(d)]


myModel2 <- lm(`Lafayette Square` ~ temp+feelslikemax+feelslikemin+dew+humidity+
                 windgust+sealevelpressure+cloudcover+visibility+solarradiation+solarenergy+
                 uvindex+precipcover+snow+snowdepth, data = tr)
summary(myModel2)

mlrB <- regsubsets(`Lafayette Square` ~ temp+feelslikemax+feelslikemin+dew+humidity+
                     windgust+sealevelpressure+cloudcover+visibility+solarradiation+solarenergy+
                     uvindex+precipcover+snow+snowdepth
                   , data = tr
                   , nbest = 1           # 1 best model for each number of predictors
                   , intercept = T       # should model have intercept term (B0)?
                   , method = "backward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL        # NULL for no limit on number of variables
)
summary(mlrB)
model_summary <- summary(mlrB)

myModel2 <- lm(`Lafayette Square` ~ temp * feelslike + humidity + feelslikemax * feelslikemin + dew + 
                  sealevelpressure  + solarradiation 
                   , data = tr)
summary(myModel2)

myModel3 <-  lm(`Lafayette Square` ~  temp * humidity  + feelslikemax * feelslikemin + dew + 
                   windgust + sealevelpressure + cloudcover + visibility + solarradiation * 
                   solarenergy + uvindex + precipcover + snow + snowdepth, data = tr) 
summary(myModel3)
View(d)

humidity.fit <- lm(`Lafayette Square` ~ humidity, data = tr)
summary(humidity.fit)


################################################################################
# Specify cross-validation design
################################################################################
ctrl <- trainControl(
  method = "cv",               # Cross-validation approach
  number = 3,                  # 3-fold cross-validation
  summaryFunction = defaultSummary,  # Use default metrics for regression (RMSE, Rsquared)
  allowParallel = TRUE         # Parallel processing if needed
)


names(tr)

myModel1 <- train(`Lafayette Square` ~ temp+feelslikemax+feelslikemin+dew+humidity+
                    windgust+sealevelpressure+cloudcover+visibility+solarradiation+solarenergy+
                    uvindex+precipcover+snow+snowdepth,               # model specification
                  data = tr,        # train set used to build model
                  method = "nnet",      # type of model you want to build
                  trControl = ctrl,
                  tuneGrid = tuneGrid
                  # how you want to learn

                  metric = "Rsquared",
                     # performance measure
)
myModel1

View(d)


# Make predictions on the test set
logit1_tep <- predict(myModel2, newdata = te, type = 'response')

# View the predictions
head(logit1_tep)

# Plot predicted vs actual values for the test set
plot(te$`Lafayette Square`, logit1_tep, 
     xlab = "Actual Values", 
     ylab = "Predicted Values", 
     main = "Predicted vs Actual: Test Dataset", 
     pch = 19, col = "blue")

# Add a line of perfect prediction
abline(0, 1, col = "red", lty = 2)  # red dashed line for perfect prediction


myGrid <-  expand.grid(size = c(10,15,20)     # number of units in the hidden layer.
                       , decay = c(.09,0.12))  #parameter for weight decay. Default 0.
myModel4 <- train(`Lafayette Square` ~ temp+feelslikemax+feelslikemin+dew+humidity+
                    windgust+sealevelpressure+cloudcover+visibility+solarradiation+solarenergy+
                    uvindex+precipcover+snow+snowdepth,              # model specification
                  data = tr,       # train set used to build model
                  method = "nnet",    # type of model you want to build
                  trControl = ctrl,   # how you want to learn
                  tuneGrid = myGrid,  # tuning parameter combos to try
                  maxit = 100,        # max # of iterations
                  metric = "Rsquared"      # performance measure
)
myModel4




############################################################################################################################
# Making model

# 1: Lafayette Square
lafayette.model <- lm(formula = `Lafayette Square` ~ temp * humidity + feelslikemax * 
     feelslikemin + dew + windgust + sealevelpressure + cloudcover + 
     visibility + solarradiation * solarenergy + uvindex + precipcover + 
     snow + snowdepth, data = tr)
summary(lafayette.model)

logit1_tep <- predict(lafayette.model, newdata = te, type = 'response')

# Plot predicted vs actual values for the test set
plot(te$`Lafayette Square`, logit1_tep, 
     xlab = "Actual Values", 
     ylab = "Predicted Values", 
     main = "Predicted vs Actual: Test Dataset", 
     pch = 19, col = "blue")

# Add a line of perfect prediction
abline(0, 1, col = "red", lty = 2)

# 2: Market Square
market.model <- lm(formula = `Market Square` ~ temp * humidity + feelslikemax * 
                        feelslikemin + dew + windgust + sealevelpressure + cloudcover + 
                        visibility + solarradiation * solarenergy + uvindex + precipcover + 
                        snow + snowdepth, data = tr)
summary(market.model)

logit2_tep <- predict(market.model, newdata = te, type = 'response')

# Plot predicted vs actual values for the test set
plot(te$`Market Square`, logit2_tep, 
     xlab = "Actual Values", 
     ylab = "Predicted Values", 
     main = "Predicted vs Actual: Test Dataset", 
     pch = 19, col = "blue")

# Add a line of perfect prediction
abline(0, 1, col = "red", lty = 2)

# 3: Northwestern
northwestern.model <- lm(formula = Northwestern ~ temp * humidity + feelslikemax * 
                        feelslikemin + dew + windgust + sealevelpressure + cloudcover + 
                        visibility + solarradiation * solarenergy + uvindex + precipcover + 
                        snow + snowdepth, data = tr)
summary(northwestern.model)

logit3_tep <- predict(northwestern.model, newdata = te, type = 'response')

# Plot predicted vs actual values for the test set
plot(te$Northwestern, logit3_tep, 
     xlab = "Actual Values", 
     ylab = "Predicted Values", 
     main = "Predicted vs Actual: Test Dataset", 
     pch = 19, col = "blue")

# Add a line of perfect prediction
abline(0, 1, col = "red", lty = 2)

# 4: Salisbury 
salisbury.model <- lm(formula = `Lafayette Square` ~ temp * humidity + feelslikemax * 
                        feelslikemin + dew + windgust + sealevelpressure + cloudcover + 
                        visibility + solarradiation * solarenergy + uvindex + precipcover + 
                        snow + snowdepth, data = tr)
summary(salisbury.model)

logit4_tep <- predict(salisbury.model, newdata = te, type = 'response')

# Plot predicted vs actual values for the test set
plot(te$Salisbury, logit4_tep, 
     xlab = "Actual Values", 
     ylab = "Predicted Values", 
     main = "Predicted vs Actual: Test Dataset", 
     pch = 19, col = "blue")

# Add a line of perfect prediction
abline(0, 1, col = "red", lty = 2)

# 5: Union St
union.model <- lm(formula = `Union St` ~ temp * humidity + feelslikemax * 
                        feelslikemin + dew + windgust + sealevelpressure + cloudcover + 
                        visibility + solarradiation * solarenergy + uvindex + precipcover + 
                        snow + snowdepth, data = tr)
summary(union.model)

logit5_tep <- predict(union.model, newdata = te, type = 'response')

# Plot predicted vs actual values for the test set
plot(te$`Union St`, logit5_tep, 
     xlab = "Actual Values", 
     ylab = "Predicted Values", 
     main = "Predicted vs Actual: Test Dataset", 
     pch = 19, col = "blue")

# Add a line of perfect prediction
abline(0, 1, col = "red", lty = 2)





