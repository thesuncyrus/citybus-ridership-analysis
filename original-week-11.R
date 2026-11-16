getwd()
library(readxl)
library(caret)
d <- read_xlsx("Off Campus routes.xlsx", sheet=2, col_names = TRUE)
d <- as.data.frame(d)
d$WorkDate <- as.Date(d$WorkDate)
dim(d)
str(d)

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



d3_1 <- d[240:268, c(2, 6:ncol(d))]

str(d3_1)

preProcValues <- preProcess(d3_1[,2:ncol(d3_1)], method = c("range"))
d3_1 <- predict(preProcValues, d3_1)

hist(d3_1$tempmin)

d3_copy <- d3_1
d3_copy$`1A` <- log(d3_copy$`1A` + 1)  # Adding 1 to handle zero values if they exist
d3_copy$y <- NULL

model4 <- lm(`1A` ~ precipprob+precipcover+winddir+sealevelpressure+cloudcover+visibility+severerisk, data=d3_copy)
summary(model4)









mlrB <- regsubsets(`1A` ~ ., data = d3_1,
                   
                   , nbest = 1           # 1 best model for each number of predictors
                   , intercept = T       # should model have intercept term (B0)?
                   , method = "backward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL        # NULL for no limit on number of variables
)
summary(mlrB)$which[which.max(summary(mlrB)$adjr2),]

# Model 4:
model4 <- lm(`1A` ~  precipprob+precipcover+ sealevelpressure+visibility+severerisk, 
             data = d3_1)
summary(model4)

predicted_values <- predict(model4, newdata = d3_1)
actual_values <- d3_1$`1A`  # Assuming "y" is your target variable
residuals <- actual_values - predicted_values
hist(residuals)

### Remove non-variable features
nzv <- nearZeroVar(d3_1, saveMetrics = TRUE)
d3_1 <- d3_1[, c(TRUE,!nzv$zeroVar[2:ncol(d3_1)])]

library(caret)
descrCor <-  cor(d3_1[,2:ncol(d3_1)])                           # correlation matrix
highCorr <- sum(abs(descrCor[upper.tri(descrCor)]) > .75) # num Xs with cor > t
summary(descrCor[upper.tri(descrCor)])                    # summarize the cors

# which columns in your correlation matrix have a correlation greater than some
# specified absolute cutoff. Find them and remove them
highlyCorDescr <- findCorrelation(descrCor, cutoff = 0.75)

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

preProcValues <- preProcess(d3_1[,2:ncol(d3_1)], method = c("center", "scale", "YeoJohnson"))
# Step 2) the predict() function actually does the transformation using the 
# parameters identified in the previous step. Weird that it uses predict() to do 
# this, but it does!
d3_1 <- predict(preProcValues, d3_1)

mlrB <- regsubsets(`1A` ~ ., data = d3_1,
                   
                   , nbest = 1           # 1 best model for each number of predictors
                   , intercept = T       # should model have intercept term (B0)?
                   , method = "backward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL        # NULL for no limit on number of variables
)
summary(mlrB)$which[which.max(summary(mlrB)$adjr2),]

model5 <- lm(`1A` ~ precipprob+precipcover+winddir+sealevelpressure+visibility+uvindex+severerisk, 
             data = d3_clean)
summary(model5)






predicted_values <- predict(model5, newdata = d3_clean)
actual_values <- d3_1$`1A`  # Assuming "y" is your target variable
residuals <- actual_values - predicted_values
hist(residuals)

model6 <- lm(y ~ precipcover+visibility+severerisk+moonphase, data=d3_1)
summary(model6)

hist(d3_1$`1A`, main = "Histogram of y", xlab = "y") 

# Get residuals from your model
residuals <- residuals(model_poly)

# Plot boxplot to visualize outliers
boxplot(residuals, main = "Residuals Boxplot", ylab = "Residuals", col = "lightblue")

# Find outliers using IQR method
Q1 <- quantile(residuals, 0.25)  # First quartile
Q3 <- quantile(residuals, 0.75)  # Third quartile
IQR_res <- Q3 - Q1  # Interquartile range

# Define lower and upper bounds
lower_bound <- Q1 - 1.5 * IQR_res
upper_bound <- Q3 + 1.5 * IQR_res

# Identify outlier indices
outlier_indices <- which(residuals < lower_bound | residuals > upper_bound)
outlier_indices

d3_clean <- d3_1[-c(242, 262), ]
model_poly <- lm(`1A` ~ poly(precipcover, 2) + visibility + severerisk + moonphase, data = d3_clean)
summary(model_poly)
hist(residuals)

library(ggplot2)
# Get predictions
predictions <- predict(model_poly, newdata = d3_1)

# Create a data frame for plotting
plot_data <- data.frame(Actual = d3_1$`1A`, Predicted = predictions)
ggplot(plot_data, aes(x = Actual, y = Predicted)) +
  geom_point(color = "blue", size = 3) +  # Scatter plot
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +  # Ideal 1:1 line
  labs(title = "Predicted vs. Actual Values",
       x = "Actual Values",
       y = "Predicted Values") +
  theme_minimal()

