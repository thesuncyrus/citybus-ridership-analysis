# Archival excerpt from Weekly Analysis/Week 8 analysis.R.
# Route 6A interaction trials; separate from the final Route 1A comparison.
# Requires d prepared in the original exploratory session (screening/imputation).
# Not sourced by run_all.R. No new results or model runs are represented here.
# The original formulas, duplicate trial and model names are preserved.

d3 <- d[59:148, 2:ncol(d)]

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

