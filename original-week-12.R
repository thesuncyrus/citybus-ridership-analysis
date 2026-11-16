getwd()
library(readxl)
library(caret)
#install.packages("lm.beta")
library(lm.beta)

d <- read_xlsx("Off Campus routes.xlsx", sheet=2, col_names = TRUE)
d <- as.data.frame(d)
d$WorkDate <- as.Date(d$WorkDate)

head(d, n=2)
d <- d[, 2:ncol(d)]

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

## Feature importance:
d1 <- d[, 5:ncol(d)]

model <- lm(mean_ridership ~ ., data = d1)

# Get standardized coefficients
lm.beta(model)
# Load necessary library
# Create a data frame with standardized coefficients
coefficients <- data.frame(
  Feature = c("tempmax", "tempmin", "temp", "feelslikemax", "feelslikemin", "feelslike", "dew", 
              "humidity", "precip", "precipprob", "precipcover", "snow", "snowdepth", 
              "windgust", "windspeed", "winddir", "sealevelpressure", "cloudcover", 
              "visibility", "solarradiation", "solarenergy", "uvindex", "severerisk", "moonphase"),
  Coefficient = c(-0.982348358, -1.296931358, 0.772752165, 0.240396250, 0.768074092, -0.230251035, 
                  1.073684457, -0.466750327, -0.137075548, -0.184511476, 0.061177996, -0.068684838, 
                  0.011556386, 0.169673850, -0.140603271, 0.005309754, 0.113299806, -0.025463725, 
                  0.044478917, 4.512052309, -4.865593801, 0.039497982, -0.046115407, -0.004847351)
)

# Create a bar plot to visualize feature importance
library(ggplot2)
ggplot(coefficients, aes(x = reorder(Feature, abs(Coefficient)), y = Coefficient, fill = Coefficient)) +
  geom_bar(stat = "identity") +
  coord_flip() +  # Flip the axes for readability
  labs(title = "Feature Importance Based on Standardized Coefficients",
       x = "Feature",
       y = "Standardized Coefficient") +
  theme_minimal() +
  theme(axis.text.y = element_text(size = 8))  # Adjust text size for readability








































