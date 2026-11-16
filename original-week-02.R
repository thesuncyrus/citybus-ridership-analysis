getwd()
#library(readxl)

# Load in Ridership dataset
df <- read_xlsx("Datasets of Ridership and Variables.xlsx", sheet = 2, col_names = T)
head(df, n = 5)
df <- as.data.frame(df)
head(df, n = 5)
str(df)
View(df)

# Model 1: Multiple linear regression: 
model_1 <- lm(Ridership ~ ., data = df)
summary(model_1)
# p-values are large
# R-squared is small

# Correlation matrix
#(corr_matrix <- cor(df, use="complete.obs"))  # Compute correlation
numeric_df <- df[sapply(df, is.numeric)]
(corr_matrix <- cor(numeric_df, use = "complete.obs"))

rownames(df$`Work date`) <- df$`Work date`
df <- df[,-1]

# Model 2
model_2 <- lm(Ridership ~ temp + precip, data = df)
summary(model_2)

plot(df$temp, df$Ridership)
plot(df$precip, df$Ridership)

# Model 3: Multiple linear regression 
model_3 <- lm(Ridership ~ tempmax + tempmin + temp + feelslikemax + feelslikemin + feelslike +
                dew + humidity + precip + precipprob + precipcover + snow + snowdepth +
                windgust + windspeed + winddir + sealevelpressure + cloudcover + visibility + 
                solarradiation + solarenergy + uvindex + severerisk, data = df)
summary(model_3)

# Backward variable selection
library(leaps)
# backward selection
mlrF <- regsubsets(Ridership ~ tempmax + tempmin + temp + feelslikemax + feelslikemin + feelslike +
                     dew + humidity + precip + precipprob + precipcover + snow + snowdepth +
                     windgust + windspeed + winddir + sealevelpressure + cloudcover + visibility + 
                     solarradiation + solarenergy + uvindex + severerisk
                   , data = df
                   , nbest = 1          # 1 best model for each number of predictors
                   , intercept = T      # should model have intercept term (B0)?
                   , method = "backward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL       # NULL for no limit on number of variables
)
summary(mlrF)

# Forward variable selection 
mlrF_f <- regsubsets(Ridership ~ tempmax + tempmin + temp + feelslikemax + feelslikemin + feelslike +
                     dew + humidity + precip + precipprob + precipcover + snow + snowdepth +
                     windgust + windspeed + winddir + sealevelpressure + cloudcover + visibility + 
                     solarradiation + solarenergy + uvindex + severerisk
                   , data = df
                   , nbest = 1          # 1 best model for each number of predictors
                   , intercept = T      # should model have intercept term (B0)?
                   , method = "forward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL       # NULL for no limit on number of variables
)
summary(mlrF_f)

plot(summary(mlrF)$bic, type = "b")  # BIC values for each model size
(best_model_size <- which.min(summary(mlrF)$bic))
names(which(summary(mlrF)$which[5, ] == TRUE))

# Best model so far
model_4 <- lm(Ridership ~ tempmax + feelslikemax + snowdepth + visibility + uvindex, data = df)
summary(model_4)
# Prediction 
df$predicted_ridership <- predict(model_4, newdata = df)
library(ggplot2)

ggplot(df, aes(x = Ridership, y = predicted_ridership)) +
  geom_point(color = "blue") +  # Scatter points
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") + # Ideal 1:1 line
  labs(title = "Actual vs. Predicted Ridership",
       x = "Actual Ridership",
       y = "Predicted Ridership") +
  theme_minimal()

ggplot(df, aes(x = predicted_ridership, y = Ridership - predicted_ridership)) +
  geom_point(color = "purple") +
  geom_hline(yintercept = 0, color = "black", linetype = "dashed") +
  labs(title = "Residuals vs. Predicted Ridership",
       x = "Predicted Ridership",
       y = "Residuals (Actual - Predicted)") +
  theme_minimal()

library(ggplot2)

# Calculate standardized residuals
df$std_residuals <- rstandard(model_4)

# Create the plot
ggplot(df, aes(x = predicted_ridership, y = std_residuals)) +
  geom_point(color = "blue") +  # Scatter points
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +  # Zero line
  labs(title = "Standardized Residuals vs. Predicted Ridership",
       x = "Predicted Ridership",
       y = "Standardized Residuals") +
  theme_minimal()


model_5 <- lm(Ridership ~ tempmax*feelslikemax + snowdepth + visibility + uvindex, data = df)
summary(model_5)
