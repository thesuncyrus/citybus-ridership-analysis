library(readxl)
getwd()

# Purdue Routes - January 2023
jan_routes <- read_xlsx("Custom - Board and Alight Totals for Purdue Routes 202301.xlsx", sheet= 1 , col_names=T)
head(jan_routes, n = 5)
str(jan_routes)
(jan_routes$Route <- as.factor(jan_routes$Route))
?sum()
jan_silver <- sum(jan_routes$Boards[jan_routes$Route == "Silver Loop"], na.rm = FALSE) # Sum of boards for Silver Loop in Jan is 57,140
jan_gold <- sum(jan_routes$Boards[jan_routes$Route == "Gold Loop"], na.rm = FALSE) # Sum of boards for Gold Loop in Jan is 20,901 
jan_ross <- sum(jan_routes$Boards[jan_routes$Route == "Ross Ade"], na.rm = FALSE) # Sum of boards for Ross Ade in Jan is 3,854
jan_tower <- sum(jan_routes$Boards[jan_routes$Route == "Tower Acres"], na.rm = FALSE) # Sum of boards for Tower Acres in Jan is 35,434


# Purdue Routes - February 2023
feb_routes <- read_xlsx("Custom - Board and Alight Totals for Purdue Routes 202302.xlsx", sheet= 1 , col_names=T)
head(feb_routes, n = 5)
str(feb_routes)
(feb_routes$Route <- as.factor(feb_routes$Route))
feb_silver <- sum(feb_routes$Boards[feb_routes$Route == "Silver Loop"], na.rm = FALSE) # Sum of boards for Silver Loop in Feb is 70,425
feb_gold <- sum(feb_routes$Boards[feb_routes$Route == "Gold Loop"], na.rm = FALSE) # Sum of boards for Gold Loop in Feb is 29,956 
feb_ross <- sum(feb_routes$Boards[feb_routes$Route == "Ross Ade"], na.rm = FALSE) # Sum of boards for Ross Ade in Feb is 3,470 
feb_tower <- sum(feb_routes$Boards[feb_routes$Route == "Tower Acres"], na.rm = FALSE) # Sum of boards for Tower Acres in Feb is 40,487


# Purdue Routes - March 2023
mar_routes <- read_xlsx("Custom - Board and Alight Totals for Purdue Routes 202303.xlsx", sheet= 1 , col_names=T)
head(mar_routes, n = 5)
str(mar_routes)
(mar_routes$Route <- as.factor(mar_routes$Route))
mar_silver <- sum(mar_routes$Boards[mar_routes$Route == "Silver Loop"], na.rm = FALSE) # Sum of boards for Silver Loop in Mar is 53,625
mar_gold <- sum(mar_routes$Boards[mar_routes$Route == "Gold Loop"], na.rm = FALSE) # Sum of boards for Gold Loop in Mar is 24,211
mar_ross <- sum(mar_routes$Boards[mar_routes$Route == "Ross Ade"], na.rm = FALSE) # Sum of boards for Ross Ade in Mar is 2,487 
mar_tower <- sum(mar_routes$Boards[mar_routes$Route == "Tower Acres"], na.rm = FALSE) # Sum of boards for Tower Acres in Mar is 28,280


# Purdue Routes - April 2023
apr_routes <- read_xlsx("Custom - Board and Alight Totals for Purdue Routes 202304.xlsx", sheet= 1 , col_names=T)
head(apr_routes, n = 5)
str(apr_routes)
(apr_routes$Route <- as.factor(apr_routes$Route))
apr_silver <- sum(apr_routes$Boards[apr_routes$Route == "Silver Loop"], na.rm = FALSE) # Sum of boards for Silver Loop in Apr is 49,571
apr_gold <- sum(apr_routes$Boards[apr_routes$Route == "Gold Loop"], na.rm = FALSE) # Sum of boards for Gold Loop in Apr is 26,531
apr_ross <- sum(apr_routes$Boards[apr_routes$Route == "Ross Ade"], na.rm = FALSE) # Sum of boards for Ross Ade in Apr is 2,605 
apr_tower <- sum(apr_routes$Boards[apr_routes$Route == "Tower Acres"], na.rm = FALSE) # Sum of boards for Tower Acres in Apr is 33,352


# Purdue Routes - May 2023
may_routes <- read_xlsx("Custom - Board and Alight Totals for Purdue Routes 202305.xlsx", sheet= 1 , col_names=T)
head(may_routes, n = 5)
str(may_routes)
(may_routes$Route <- as.factor(may_routes$Route))
may_silver <- sum(may_routes$Boards[may_routes$Route == "Silver Loop"], na.rm = FALSE) # Sum of boards for Silver Loop in May is 6,077
may_gold <- sum(may_routes$Boards[may_routes$Route == "Gold Loop"], na.rm = FALSE) # Sum of boards for Gold Loop in May is 3,000
may_ross <- sum(may_routes$Boards[may_routes$Route == "Ross Ade"], na.rm = FALSE) # Sum of boards for Ross Ade in May is 261 
may_tower <- sum(may_routes$Boards[may_routes$Route == "Tower Acres"], na.rm = FALSE) # Sum of boards for Tower Acres in May is 4,542


# Purdue Routes - August 2023
aug_routes <- read_xlsx("Custom - Board and Alight Totals for Purdue Routes 202308.xlsx", sheet= 1 , col_names=T)
head(aug_routes, n = 5)
str(aug_routes)
(aug_routes$Route <- as.factor(aug_routes$Route))
aug_silver <- sum(aug_routes$Boards[aug_routes$Route == "Silver Loop"], na.rm = FALSE) # Sum of boards for Silver Loop in Aug is 19,154
aug_gold <- sum(aug_routes$Boards[aug_routes$Route == "Gold Loop"], na.rm = FALSE) # Sum of boards for Gold Loop in Aug is 9,288
aug_tower <- sum(aug_routes$Boards[aug_routes$Route == "Tower Acres"], na.rm = FALSE) # Sum of boards for Tower Acres in Aug is 16,693
aug_black <- sum(aug_routes$Boards[aug_routes$Route == "Black Loop"], na.rm = FALSE) # Sum of boards for Black Loop in Aug is 860
aug_campus <- sum(aug_routes$Boards[aug_routes$Route == "South Campus"], na.rm = FALSE) # Sum of boards for South Campus in Aug is 491
aug_south <- sum(aug_routes$Boards[aug_routes$Route == "South Loop"], na.rm = FALSE) # Sum of boards for South Loop in Aug is 106



# Purdue Routes - September 2023
sep_routes <- read_xlsx("Custom - Board and Alight Totals for Purdue Routes 202309.xlsx", sheet= 1 , col_names=T)
head(sep_routes, n = 5)
str(sep_routes)
(sep_routes$Route <- as.factor(sep_routes$Route))
sep_silver <- sum(sep_routes$Boards[sep_routes$Route == "Silver Loop"], na.rm = FALSE) # Sum of boards for Silver Loop in Sep is 34,871
sep_gold <- sum(sep_routes$Boards[sep_routes$Route == "Gold Loop"], na.rm = FALSE) # Sum of boards for Gold Loop in sep is 16,854
sep_tower <- sum(sep_routes$Boards[sep_routes$Route == "Tower Acres"], na.rm = FALSE) # Sum of boards for Tower Acres in sep is 32,539
sep_black <- sum(sep_routes$Boards[sep_routes$Route == "Black Loop"], na.rm = FALSE) # Sum of boards for Black Loop in Sep is 1,236
sep_campus <- sum(sep_routes$Boards[sep_routes$Route == "South Campus"], na.rm = FALSE) # Sum of boards for South Campus in Sep is 1515


# Purdue Routes - October 2023
oct_routes <- read_xlsx("Custom - Board and Alight Totals for Purdue Routes 202310.xlsx", sheet= 1 , col_names=T)
head(oct_routes, n = 5)
str(oct_routes)
(oct_routes$Route <- as.factor(oct_routes$Route))
oct_silver <- sum(oct_routes$Boards[oct_routes$Route == "Silver Loop"], na.rm = FALSE) # Sum of boards for Silver Loop in Oct is 33,449
oct_gold <- sum(oct_routes$Boards[oct_routes$Route == "Gold Loop"], na.rm = FALSE) # Sum of boards for Gold Loop in Oct is 17,033
oct_tower <- sum(oct_routes$Boards[oct_routes$Route == "Tower Acres"], na.rm = FALSE) # Sum of boards for Tower Acres in Oct is 30,955
oct_black <- sum(oct_routes$Boards[oct_routes$Route == "Black Loop"], na.rm = FALSE) # Sum of boards for Black Loop in Oct is 1,308
oct_campus <- sum(oct_routes$Boards[oct_routes$Route == "South Campus"], na.rm = FALSE) # Sum of boards for South Campus in Oct is 1,059


# Purdue Routes - November 2023
nov_routes <- read_xlsx("Custom - Board and Alight Totals for Purdue Routes 202311.xlsx", sheet= 1 , col_names=T)
head(nov_routes, n = 5)
str(nov_routes)
(nov_routes$Route <- as.factor(nov_routes$Route))
nov_silver <- sum(nov_routes$Boards[nov_routes$Route == "Silver Loop"], na.rm = FALSE) # Sum of boards for Silver Loop in Nov is 36,185
nov_gold <- sum(nov_routes$Boards[nov_routes$Route == "Gold Loop"], na.rm = FALSE) # Sum of boards for Gold Loop in Nov is 16,096
nov_tower <- sum(nov_routes$Boards[nov_routes$Route == "Tower Acres"], na.rm = FALSE) # Sum of boards for Tower Acres in Nov is 25,659
nov_black <- sum(nov_routes$Boards[nov_routes$Route == "Black Loop"], na.rm = FALSE) # Sum of boards for Black Loop in Nov is 1,277
nov_campus <- sum(nov_routes$Boards[nov_routes$Route == "South Campus"], na.rm = FALSE) # Sum of boards for South Campus in Nov is 1,034


# Purdue Routes - December 2023
dec_routes <- read_xlsx("Custom - Board and Alight Totals for Purdue Routes 202312.xlsx", sheet= 1 , col_names=T)
head(dec_routes, n = 5)
str(dec_routes)
(dec_routes$Route <- as.factor(dec_routes$Route))
dec_silver <- sum(dec_routes$Boards[dec_routes$Route == "Silver Loop"], na.rm = FALSE) # Sum of boards for Silver Loop in Dec is 17,525
dec_gold <- sum(dec_routes$Boards[dec_routes$Route == "Gold Loop"], na.rm = FALSE) # Sum of boards for Gold Loop in Dec is 6,039
dec_tower <- sum(dec_routes$Boards[dec_routes$Route == "Tower Acres"], na.rm = FALSE) # Sum of boards for Tower Acres in Dec is 9,688
dec_black <- sum(dec_routes$Boards[dec_routes$Route == "Black Loop"], na.rm = FALSE) # Sum of boards for Black Loop in Dec is 645
dec_campus <- sum(dec_routes$Boards[dec_routes$Route == "South Campus"], na.rm = FALSE) # Sum of boards for South Campus in Dec is 493


# Weather in 2023
weather <- read_xlsx("KLAF 2023-01-01 to 2023-12-31.xlsx", sheet= 1 , col_names=T)
head(weather, n = 5)
str(weather)

rm(weather_jan, weather_feb, weather_mar, weather_apr, weather_may, weather_aug, weather_sep, weather_oct, weather_nov, weather_dec)

# Temperature by month
# Step 1: Average of Temperature by month
?mean()
head(weather, n = 5)
weather$temp <- as.numeric(weather$temp)


## Temperature average of 10 months
(temp_jan <- weather[2:21, "temp"])
temp_jan <- as.data.frame(temp_jan)
temp_jan
temp_jan_avg <- mean(temp_jan$temp)

temp_feb <- weather[33:60, "temp"]
temp_feb <- as.data.frame(temp_feb)
temp_feb_avg <- mean(temp_feb$temp)

temp_mar <- weather[61:91, "temp"]
temp_mar <- as.data.frame(temp_mar)
temp_mar_avg <- mean(temp_mar$temp)

temp_apr <- weather[92:121, "temp"]
temp_apr <- as.data.frame(temp_apr)
temp_apr_avg <- mean(temp_apr$temp)

temp_may <- weather[122:152, "temp"]
temp_may <- as.data.frame(temp_may)
temp_may_avg <- mean(temp_may$temp)

temp_aug <- weather[214:244, "temp"]
temp_aug <- as.data.frame(temp_aug)
temp_aug_avg <- mean(temp_aug$temp)

temp_sep <- weather[245:274, "temp"]
temp_sep <- as.data.frame(temp_sep)
temp_sep_avg <- mean(temp_sep$temp)

temp_oct <- weather[275:305, "temp"]
temp_oct <- as.data.frame(temp_oct)
temp_oct_avg <- mean(temp_oct$temp)

temp_nov <- weather[306:335, "temp"]
temp_nov <- as.data.frame(temp_nov)
temp_nov_avg <- mean(temp_nov$temp)

(temp_dec <- weather[336:365, "temp"])
(temp_dec <- as.data.frame(temp_dec))
(temp_dec_avg <- mean(temp_dec$temp))


(combined_temperature <- c(temp_jan_avg, temp_feb_avg,temp_mar_avg,temp_apr_avg,temp_may_avg,
                              temp_aug_avg,temp_sep_avg, temp_oct_avg, temp_nov_avg,temp_dec_avg  ))

# Snow
(temp_jan <- weather[2:21, "temp"])
temp_jan <- as.data.frame(temp_jan)
temp_jan
temp_jan_avg <- mean(temp_jan$temp)

temp_feb <- weather[33:60, "temp"]
temp_feb <- as.data.frame(temp_feb)
temp_feb_avg <- mean(temp_feb$temp)

temp_mar <- weather[61:91, "temp"]
temp_mar <- as.data.frame(temp_mar)
temp_mar_avg <- mean(temp_mar$temp)

temp_apr <- weather[92:121, "temp"]
temp_apr <- as.data.frame(temp_apr)
temp_apr_avg <- mean(temp_apr$temp)

temp_may <- weather[122:152, "temp"]
temp_may <- as.data.frame(temp_may)
temp_may_avg <- mean(temp_may$temp)

temp_aug <- weather[214:244, "temp"]
temp_aug <- as.data.frame(temp_aug)
temp_aug_avg <- mean(temp_aug$temp)

temp_sep <- weather[245:274, "temp"]
temp_sep <- as.data.frame(temp_sep)
temp_sep_avg <- mean(temp_sep$temp)

temp_oct <- weather[275:305, "temp"]
temp_oct <- as.data.frame(temp_oct)
temp_oct_avg <- mean(temp_oct$temp)

temp_nov <- weather[306:335, "temp"]
temp_nov <- as.data.frame(temp_nov)
temp_nov_avg <- mean(temp_nov$temp)

(temp_dec <- weather[336:365, "temp"])
(temp_dec <- as.data.frame(temp_dec))
(temp_dec_avg <- mean(temp_dec$temp))


(combined_temperature <- c(temp_jan_avg, temp_feb_avg,temp_mar_avg,temp_apr_avg,temp_may_avg,
                           temp_aug_avg,temp_sep_avg, temp_oct_avg, temp_nov_avg,temp_dec_avg  ))


# Calculate the monthly sums
sum_boards_aug <- aug_silver + aug_gold + aug_black + aug_south + aug_campus + aug_tower
sum_boards_may <- may_silver + may_gold + may_tower + may_ross
sum_boards_sep <- sep_silver + sep_gold + sep_black + sep_campus + sep_tower
sum_boards_oct <- oct_silver + oct_gold + oct_black + oct_campus + oct_tower
sum_boards_nov <- nov_silver + nov_gold + nov_black + nov_campus + nov_tower
sum_boards_dec <- dec_silver + dec_gold + dec_black + dec_campus + dec_tower

# Combine into a vector of total boards
(Sum_of_Boards <- c(sum_boards_jan, sum_boards_feb, sum_boards_mar, sum_boards_apr, 
                   sum_boards_may, sum_boards_aug, sum_boards_sep, 
                   sum_boards_oct, sum_boards_nov, sum_boards_dec))


## Correlation between temp & sum of boards
correlation <- cor(combined_temperature, Sum_of_Boards)
print(correlation)




(weather_boards <- data.frame(weather = combined_temperature, sum_of_boards = Sum_of_Boards))
model <- lm(Sum_of_Boards ~ combined_temperature)
# Plot the data points
plot(combined_temperature, Sum_of_Boards, main = "Simple Linear Regression", xlab = "Temperature", ylab = "Number of Boards", col = "blue", pch = 16)

# Add the regression line
abline(model, col = "red")

summary(model)

ridership_weather <- read_xlsx("Custom - Board and Alight Totals for Purdue Routes 202301.xlsx", sheet= 2 , col_names=T)
View(ridership_weather)
plot(ridership_weather$temp, ridership_weather$`Daily total Boards`)

model_2 <- lm(`Daily total Boards` ~ temp, data = ridership_weather)
# Add the regression line
abline(model_2, col = "red")
summary(model_2)


# Handle outliers
Q1 <- quantile(ridership_weather$`Daily total Boards`, 0.25)
Q3 <- quantile(ridership_weather$`Daily total Boards`, 0.75)
IQR_value <- Q3 - Q1

lower_bound <- Q1 - 1.5 * IQR_value
upper_bound <- Q3 + 1.5 * IQR_value

ridership_weather_clean <- ridership_weather[ridership_weather$`Daily total Boards` >= lower_bound & 
                                               ridership_weather$`Daily total Boards` <= upper_bound, ]

model_clean <- lm(`Daily total Boards` ~ temp, data = ridership_weather_clean)
summary(model_clean)

plot(ridership_weather_clean$temp, ridership_weather_clean$`Daily total Boards`)


# Polynimial
model_poly <- lm(`Daily total Boards` ~ poly(temp, 2), data = ridership_weather)
summary(model_poly)


View(ridership_weather)
model_multi <- lm(`Daily total Boards` ~ poly(temp, 2) + humidity , data = ridership_weather)
summary(model_multi)

#ts <- xts(df[, -1], order.by = df$DATE)

ts <- xts(ridership_weather[, -1], order.by = ridership_weather$Date)
head(ts)

browseURL("ridership_weather.xlsx")

# Model Week 1: Multiple linear regression: Daily total boards ~ Temp + Humidity + Precip
model_4 <- lm(`Daily total Boards` ~ temp + humidity + precip, data = ridership_weather)
summary(model_4)

# Comparison between Actual values and predicted values
plot(ridership_weather$`Daily total Boards`, predict(model_4), 
     xlab = "Actual Values", ylab = "Predicted Values", 
     main = "Actual vs Predicted Values")
abline(0, 1, col = "red")

# Residual plot
plot(model_4$residuals, main = "Residuals Plot", ylab = "Residuals", xlab = "Index")
abline(h = 0, col = "red")

# Standardized residual plots
# Compute standardized residuals
std_residuals <- rstandard(model_4)

# Create residual plot
std_residuals <- rstandard(model_4)

plot(fitted(model_4), std_residuals, 
     xlab = "Fitted Values", ylab = "Standardized Residuals",
     main = "Standardized Residual Plot", pch = 16)

# Add a horizontal reference line at 0
abline(h = 0, col = "red", lwd = 2, lty = 2)


