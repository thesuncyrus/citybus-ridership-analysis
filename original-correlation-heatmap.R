getwd()
library(readxl)
library(caret)

d <- read_xlsx("Off Campus routes.xlsx", sheet=2, col_names = TRUE)
d <- as.data.frame(d)
d$Date <- as.Date(d$Date)



d$Mean <- rowMeans(d[, 2:5])
head(d)

# Data: Mean ~ All data features
d1 <- d[, c(30, 6:29)]
head(d1)

(cor_matrix <- cor(d1, use = "complete.obs"))

# Data: Mean ~ certain features
d1 <- d1[, c("Ridership", "temp", "humidity", "precip", "precipprob", "precipcover","snow", "windspeed", 
             "cloudcover", "visibility")]

(cor_matrix <- round(cor(d1, use = "complete.obs"), 2))
# Convert matrix to long format for ggplot2
  melted_cor <- melt(cor_matrix)
# Create heatmap
ggplot(melted_cor, aes(Var1, Var2, fill = value)) +
  geom_tile() +                                   # Heatmap squares
  geom_text(aes(label = value), color = "black") + # Show correlation values
  scale_fill_gradient(low = "lightyellow", high = "darkgoldenrod4") +  # Yellow gradient
  theme_minimal() +
  labs(title = "Full Correlation Heatmap") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
# Create heatmap
  ggplot(melted_cor, aes(Var1, Var2, fill = value)) +
     geom_tile() +                                   # Heatmap squares
     geom_text(aes(label = value), color = "black") + # Show correlation values
     scale_fill_gradient(low = "lightyellow", high = "darkgoldenrod4") +  # Yellow gradient
     theme_minimal() +
     labs(title = "Correlation Heatmap") +
     theme(axis.text.x = element_text(angle = 45, hjust = 1))





































































































