# Exploratory regression and transformations.
# Original interaction trials are in archive/week08_route6a_interactions.R.
# Predictor screening and formula selection use the exploratory sample.
args <- commandArgs(trailingOnly=TRUE)
if (!length(args)) stop("Supply the authorized off-campus workbook.")
workbook <- args[1]
library(readxl)
library(caret)
source("src/time_segments.R")
out <- if(length(args)>1) args[2] else "outputs/exploratory-weather"
dir.create(out, recursive=TRUE, showWarnings=FALSE)
pdf(file.path(out, "exploratory-diagnostics.pdf"))
# Removing no columns must preserve the input, including one-column frames.
drop_columns <- function(x, indices) {
  if(length(indices)) x[, -indices, drop=FALSE] else x
}
# A screened predictor is omitted from subsequent exploratory formulas.
retained_formula <- function(predictors, data, response="y") {
  retained <- intersect(predictors, names(data))
  if(!length(retained)) stop("No requested predictors remain after screening.")
  reformulate(retained, response=as.name(response))
}
d <- if(grepl("[.]csv$",workbook,ignore.case=TRUE)) read.csv(workbook,check.names=FALSE) else read_xlsx(workbook,sheet=2,col_names=TRUE)
d <- as.data.frame(d)
d$WorkDate <- as.Date(d$WorkDate)
dim(d)

# Data Cleaning 
# Identify Correlated Predictors and remove them
# calculate correlation matrix 
descrCor <-  cor(d[,6:ncol(d)])
highCorr <- sum(abs(descrCor[upper.tri(descrCor)]) > citybus_config$screening$full_correlation_cutoff)
summary(descrCor[upper.tri(descrCor)])

highlyCorDescr <- findCorrelation(descrCor, cutoff = citybus_config$screening$full_correlation_cutoff)
filteredDescr <- drop_columns(d[,6:ncol(d),drop=FALSE], highlyCorDescr)
descrCor2 <- cor(filteredDescr)                  # calculate a new cor matrix
# summarize those correlations to see if all features are now within our range
summary(descrCor2[upper.tri(descrCor2)])

d <- cbind(d[, 1:5], filteredDescr)
rm(filteredDescr, descrCor, descrCor2, highCorr, highlyCorDescr)  # clean up


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




source_rows <- citybus_segment_rows(d, "exploratory")
d3_1 <- d[source_rows, c(2, 6:ncol(d)), drop=FALSE]


preProcValues <- preProcess(d3_1[,2:ncol(d3_1)], method = citybus_config$screening$initial_preprocess)
d3_1 <- predict(preProcValues, d3_1)

if("tempmin" %in% names(d3_1)) hist(d3_1$tempmin)

d3_copy <- d3_1
d3_copy$`1A` <- log(d3_copy$`1A` + 1)  # Adding 1 to handle zero values if they exist
d3_copy$y <- NULL

model4 <- lm(retained_formula(citybus_config$screening$log_predictors, d3_copy, "1A"), data=d3_copy)
summary(model4)









mlrB <- leaps::regsubsets(`1A` ~ ., data = d3_1,
                   
                   , nbest = citybus_config$variable_selection$nbest           # 1 best model for each number of predictors
                   , intercept = citybus_config$variable_selection$intercept       # should model have intercept term (B0)?
                   , method = citybus_config$variable_selection$method # forward, backward, sequential, exhaustive
                   , nvmax = citybus_config$variable_selection$nvmax        # NULL for no limit on number of variables
)
summary(mlrB)$which[which.max(summary(mlrB)$adjr2),]

# Model 4:
model4 <- lm(retained_formula(citybus_config$screening$initial_predictors, d3_1, "1A"),
             data = d3_1)
summary(model4)

predicted_values <- predict(model4, newdata = d3_1)
actual_values <- d3_1$`1A`  # Assuming "y" is your target variable
residuals <- actual_values - predicted_values
hist(residuals)

### Remove non-variable features
nzv <- nearZeroVar(d3_1, saveMetrics = TRUE)
d3_1 <- d3_1[, c(TRUE,!nzv$zeroVar[2:ncol(d3_1)]), drop=FALSE]

library(caret)
descrCor <-  cor(d3_1[,2:ncol(d3_1)])                           # correlation matrix
highCorr <- sum(abs(descrCor[upper.tri(descrCor)]) > citybus_config$screening$segment_correlation_cutoff) # num Xs with cor > t
summary(descrCor[upper.tri(descrCor)])                    # summarize the cors

# which columns in your correlation matrix have a correlation greater than some
# specified absolute cutoff. Find them and remove them
highlyCorDescr <- findCorrelation(descrCor, cutoff = citybus_config$screening$segment_correlation_cutoff)

sum(is.na(descrCor))  # Count NA values
colSums(is.na(d3_1))  # Identify columns with missing values


filteredDescr <- drop_columns(d3_1[,2:ncol(d3_1),drop=FALSE], highlyCorDescr)
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
d3_1 <- drop_columns(d3_1, comboInfo$remove)

# remove the "ones" column in the first column
d3_1 <- d3_1[, setdiff(names(d3_1), "ones"), drop=FALSE]

# Add the target variable back to our data.frame
d3_1 <- cbind(y, d3_1)

rm(y, comboInfo)  # clean up

preProcValues <- preProcess(d3_1[,2:ncol(d3_1)], method = citybus_config$screening$final_preprocess)
# Step 2) the predict() function actually does the transformation using the 
# parameters identified in the previous step. Weird that it uses predict() to do 
# this, but it does!
d3_1 <- predict(preProcValues, d3_1)

mlrB <- leaps::regsubsets(y ~ ., data = d3_1,
                   
                   , nbest = citybus_config$variable_selection$nbest           # 1 best model for each number of predictors
                   , intercept = citybus_config$variable_selection$intercept       # should model have intercept term (B0)?
                   , method = citybus_config$variable_selection$method # forward, backward, sequential, exhaustive
                   , nvmax = citybus_config$variable_selection$nvmax        # NULL for no limit on number of variables
)
summary(mlrB)$which[which.max(summary(mlrB)$adjr2),]

# The original exclusions refer to rows in the full input table.
excluded_source_rows <- citybus_config$screening$excluded_source_rows
keep_rows <- !source_rows %in% excluded_source_rows
d3_clean <- d3_1[keep_rows, , drop=FALSE]
write.csv(data.frame(source_row=source_rows, date=d$WorkDate[source_rows],
                    retained=keep_rows), file.path(out,"row-selection.csv"), row.names=FALSE)
model5 <- lm(retained_formula(citybus_config$screening$cleaned_predictors, d3_clean),
             data = d3_clean)
summary(model5)






predicted_values <- predict(model5, newdata = d3_clean)
actual_values <- d3_clean$y
residuals <- actual_values - predicted_values
hist(residuals)

model6 <- lm(retained_formula(citybus_config$screening$final_predictors, d3_1), data=d3_1)
summary(model6)

hist(d3_1$y, main = "Histogram of y", xlab = "y")

# Fit the polynomial trial before computing its residual diagnostics.
poly_terms <- intersect(c("visibility","severerisk","moonphase"), names(d3_1))
if("precipcover" %in% names(d3_1) && length(unique(d3_1$precipcover)) > 2)
  poly_terms <- c("poly(precipcover, 2)", poly_terms)
poly_formula <- reformulate(poly_terms, response="y")
model_poly_initial <- lm(poly_formula, data=d3_1)
residuals <- residuals(model_poly_initial)

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

model_poly <- lm(poly_formula, data = d3_clean)
summary(model_poly)
hist(residuals)

library(ggplot2)
# Get predictions
predictions <- predict(model_poly, newdata = d3_1)

# Create a data frame for plotting
plot_data <- data.frame(Actual = d3_1$y, Predicted = predictions)
print(ggplot(plot_data, aes(x = Actual, y = Predicted)) +
  geom_point(color = "blue", size = 3) +  # Scatter plot
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +  # Ideal 1:1 line
  labs(title = "Predicted vs. Actual Values",
       x = "Actual Values",
       y = "Predicted Values") +
  theme_minimal())
dev.off()

