getwd()
library(readxl)
df <- read_xlsx("Assigned Routes.xlsx", sheet=1, col_names = TRUE)
df <- na.omit(df)
View(df)
dim(df)
str(df)
df$'Row Labels' <- as.Date(df$`Row Labels`, format = '%m/%d/%Y')

## Lafayette Square raw Ridership with all Variables
# Multiple linear regression
lafayette.lim <- lm(`Lafayette Square` ~ ., data = df[, -c(1, 3, 4, 5, 6)])
summary(lafayette.lim)
# Fordward Selection
library(leaps)
lafayette.selection <- regsubsets(`Lafayette Square` ~ ., data = df[, -c(1, 3, 4, 5, 6)]
                   , nbest = 1          # 1 best model for each number of predictors
                   , intercept = T      # should model have intercept term (B0)?
                   , method = "forward" # forward, backward, sequential, exhaustive
                   , nvmax = NULL       # NULL for no limit on number of variables
)
summary_selection <- summary(lafayette.selection)
(selected_vars <- names(coef(lafayette.selection, which.max(summary_selection$adjr2))))
## Final model for Lafayette Square
df <- na.omit(df) 
lafayette.fit <- lm(`Lafayette Square` ~ dew +precip+precipprob+snow+sealevelpressure+cloudcover+visibility+solarradiation,
                    data = df)
summary(lafayette.fit)
# Scatter plot for the above variables
df <- na.omit(df)
par(mfrow = c(2, 4))  # 2 rows, 4 columns
plot(df$'Lafayette Square', df$dew, main = "Ridership vs Dew", xlab = "TempMax", ylab = "Dew", pch = 16, col = "blue")
plot(df$'Lafayette Square', df$precip, main = "Ridership vs Precip", xlab = "TempMax", ylab = "Precip", pch = 16, col = "blue")
plot(df$'Lafayette Square', df$precipprob, main = "Ridership vs PrecipProb", xlab = "TempMax", ylab = "PrecipProb", pch = 16, col = "blue")
plot(df$'Lafayette Square', df$snow, main = "Ridership vs Snow", xlab = "TempMax", ylab = "Snow", pch = 16, col = "blue")
plot(df$'Lafayette Square', df$sealevelpressure, main = "Ridership vs SeaLevelPressure", xlab = "TempMax", ylab = "Pressure", pch = 16, col = "blue")
plot(df$'Lafayette Square', df$cloudcover, main = "Ridership vs CloudCover", xlab = "TempMax", ylab = "CloudCover", pch = 16, col = "blue")
plot(df$'Lafayette Square', df$visibility, main = "Ridership vs Visibility", xlab = "TempMax", ylab = "Visibility", pch = 16, col = "blue")
plot(df$'Lafayette Square', df$solarradiation, main = "Ridership vs SolarRadiation", xlab = "TempMax", ylab = "SolarRadiation", pch = 16, col = "blue")

## Market Square raw Ridership with all Variables
# Multiple linear regression
market.lim <- lm(`Market Square` ~ ., data = df[, -c(1, 2, 4, 5, 6)])
summary(market.lim)
# Fordward Selection
market.selection <- regsubsets(`Market Square` ~ ., data = df[, -c(1, 2, 4, 5, 6)]
                                  , nbest = 1          # 1 best model for each number of predictors
                                  , intercept = T      # should model have intercept term (B0)?
                                  , method = "forward" # forward, backward, sequential, exhaustive
                                  , nvmax = NULL       # NULL for no limit on number of variables
)
summary_selection <- summary(market.selection)
(selected_vars <- names(coef(market.selection, which.max(summary_selection$adjr2))))
## Final model for Lafayette Square
df <- na.omit(df) 
market.fit <- lm(`Market Square` ~ tempmin+temp+feelslikemin+feelslike+dew+precip+snow+windgust+sealevelpressure+severerisk+moonphase,
                    data = df)
summary(market.fit)
# Scatter plot for the above variables
df <- na.omit(df)
par(mfrow = c(2, 4))  # 2 rows, 4 columns
plot(df$'Market Square', df$tempmin, main = "Ridership vs Tempmin", pch = 16, col = "blue")
plot(df$'Market Square', df$temp, main = "Ridership vs Temp", pch = 16, col = "blue")
plot(df$'Market Square', df$feelslikemin, main = "Ridership vs Feelslikemin", pch = 16, col = "blue")
plot(df$'Market Square', df$feelslike, main = "Ridership vs Feelslike", pch = 16, col = "blue")
plot(df$'Market Square', df$dew, main = "Ridership vs Dew", pch = 16, col = "blue")
plot(df$'Market Square', df$precip, main = "Ridership vs Precip", pch = 16, col = "blue")
plot(df$'Market Square', df$snow, main = "Ridership vs Snow", pch = 16, col = "blue")
plot(df$'Market Square', df$windgust, main = "Ridership vs Windgust", pch = 16, col = "blue")
plot(df$'Market Square', df$sealevelpressure, main = "Ridership vs SeaLevelPressure",  pch = 16, col = "blue")
plot(df$'Market Square', df$severerisk, main = "Ridership vs Severerisk",  pch = 16, col = "blue")
plot(df$'Market Square', df$moonphase, main = "Ridership vs Moonphase",  pch = 16, col = "blue")


## Northwestern raw Ridership with all Variables
# Multiple linear regression
northwestern.lim <- lm(`Northwestern` ~ ., data = df[, -c(1, 2, 3, 5, 6)])

# Fordward Selection
northwestern.selection <- regsubsets(`Northwestern` ~ ., data = df[, -c(1, 2, 3, 5, 6)]
                               , nbest = 1          # 1 best model for each number of predictors
                               , intercept = T      # should model have intercept term (B0)?
                               , method = "forward" # forward, backward, sequential, exhaustive
                               , nvmax = NULL       # NULL for no limit on number of variables
)
summary_selection <- summary(northwestern.selection)
(selected_vars <- names(coef(northwestern.selection, which.max(summary_selection$adjr2))))
## Final model for Lafayette Square
df <- na.omit(df) 
northwestern.fit <- lm(`Northwestern` ~ tempmax+feelslikemax+feelslikemin+feelslike+dew+precip+precipprob+windgust+winddir+sealevelpressure+cloudcover+solarradiation+uvindex+severerisk,
                 data = df)
summary(northwestern.fit)
# Scatter plot for the above variables
df <- na.omit(df)
par(mfrow = c(3, 5))  # 2 rows, 4 columns
plot(df$'Northwestern', df$tempmax, main = "Ridership vs Tempmax", pch = 16, col = "blue")
plot(df$'Northwestern', df$feelslikemax, main = "Ridership vs Feelslikemax", pch = 16, col = "blue")
plot(df$'Northwestern', df$feelslikemin, main = "Ridership vs Feelslikemin", pch = 16, col = "blue")
plot(df$'Northwestern', df$feelslike, main = "Ridership vs Feelslike", pch = 16, col = "blue")
plot(df$'Northwestern', df$dew, main = "Ridership vs Dew", pch = 16, col = "blue")
plot(df$'Northwestern', df$precip, main = "Ridership vs Precip", pch = 16, col = "blue")
plot(df$'Northwestern', df$precipprob, main = "Ridership vs Precipprob", pch = 16, col = "blue")
plot(df$'Northwestern', df$windgust, main = "Ridership vs Windgust", pch = 16, col = "blue")
plot(df$'Northwestern', df$winddir, main = "Ridership vs Winddir", pch = 16, col = "blue")
plot(df$'Northwestern', df$sealevelpressure, main = "Ridership vs Sealevelpressure", pch = 16, col = "blue")
plot(df$'Northwestern', df$cloudcover, main = "Ridership vs Cloudcover", pch = 16, col = "blue")
plot(df$'Northwestern', df$solarradiation, main = "Ridership vs Solarradiation", pch = 16, col = "blue")
plot(df$'Northwestern', df$uvindex, main = "Ridership vs Uvindex", pch = 16, col = "blue")
plot(df$'Northwestern', df$severerisk, main = "Ridership vs Severerisk", pch = 16, col = "blue")


## Salisbury raw Ridership with all Variables
# Multiple linear regression
salisbury.lim <- lm(`Salisbury` ~ ., data = df[, -c(1, 2, 3, 4, 6)])

# Fordward Selection
salisbury.selection <- regsubsets(`Salisbury` ~ ., data = df[, -c(1, 2, 3, 4, 6)]
                                     , nbest = 1          # 1 best model for each number of predictors
                                     , intercept = T      # should model have intercept term (B0)?
                                     , method = "forward" # forward, backward, sequential, exhaustive
                                     , nvmax = NULL       # NULL for no limit on number of variables
)
summary_selection <- summary(salisbury.selection)
(selected_vars <- names(coef(salisbury.selection, which.max(summary_selection$adjr2))))
## Final model for Lafayette Square
df <- na.omit(df) 
salisbury.fit <- lm(`Salisbury` ~ feelslikemax+humidity+precip+precipprob+windgust+windspeed+sealevelpressure+cloudcover+visibility+solarradiation+severerisk,
                       data = df)
summary(salisbury.fit)
# Scatter plot for the above variables
par(mfrow = c(3, 4))  # 2 rows, 4 columns
plot(df$'Salisbury', df$feelslikemax, main = "Ridership vs Feelslikemax", pch = 16, col = "blue")
plot(df$'Salisbury', df$humidity, main = "Humidity", pch = 16, col = "blue")
plot(df$'Salisbury', df$precip, main = "Precip", pch = 16, col = "blue")
plot(df$'Salisbury', df$precipprob, main = "Precipprob", pch = 16, col = "blue")
plot(df$'Salisbury', df$windgust, main = "Windgust", pch = 16, col = "blue")
plot(df$'Salisbury', df$windspeed, main = "Windspeed", pch = 16, col = "blue")
plot(df$'Salisbury', df$sealevelpressure, main = "Sealevelpressure", pch = 16, col = "blue")
plot(df$'Salisbury', df$cloudcover, main = "Cloudcover", pch = 16, col = "blue")
plot(df$'Salisbury', df$visibility, main = "Visibility", pch = 16, col = "blue")
plot(df$'Salisbury', df$solarradiation, main = "Solarradiation", pch = 16, col = "blue")
plot(df$'Salisbury', df$severerisk, main = "Severerisk", pch = 16, col = "blue")



## Salisbury raw Ridership with all Variables
# Multiple linear regression
union.lim <- lm(`Union St` ~ ., data = df[, -c(1, 2, 3, 4, 5)])

# Fordward Selection
union.selection <- regsubsets(`Union St` ~ tempmax+tempmin+feelslikemin+precip+precipprob+precipcover+windgust+windspeed+winddir+sealevelpressure, data = df
                                  , nbest = 1          # 1 best model for each number of predictors
                                  , intercept = T      # should model have intercept term (B0)?
                                  , method = "backward" # forward, backward, sequential, exhaustive
                                  , nvmax = NULL       # NULL for no limit on number of variables
)
summary_selection <- summary(union.selection)
(selected_vars <- names(coef(union.selection, which.max(summary_selection$adjr2))))
## Final model for Lafayette Square
df <- na.omit(df) 
union.fit <- lm(`Union St` ~ tempmin+feelslikemin+precip+precipprob+precipcover+winddir,
                    data = df)
summary(union.fit)
# Scatter plot for the above variables
par(mfrow = c(2, 3))  # 2 rows, 4 columns
plot(df$'Union St', df$tempmin, main = "Tempmin", pch = 16, col = "blue")
plot(df$'Union St', df$feelslikemin, main = "Feelslikemin", pch = 16, col = "blue")
plot(df$'Union St', df$precip, main = "Precip", pch = 16, col = "blue")
plot(df$'Union St', df$precipprob, main = "Precipprob", pch = 16, col = "blue")
plot(df$'Union St', df$precipcover, main = "Precipcover", pch = 16, col = "blue")
plot(df$'Union St', df$winddir, main = "Winddir", pch = 16, col = "blue")




























































