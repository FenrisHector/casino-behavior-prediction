# ============================================
# 04 - CLASSIFICATION: LOGISTIC REGRESSION
# Project: Casino Behavior Prediction
# ============================================

library(dplyr)
library(caret)

# Simulate casino data (the real dataset contains only wins)
# 5,000 synthetic records: 60% losses, 40% wins
set.seed(123)
n <- 5000

data_simulado <- data.frame(
  Bet        = rexp(n, 1 / 100),
  hora       = sample(0:23, n, replace = TRUE),
  dia_semana = sample(1:7,  n, replace = TRUE)
) %>%
  mutate(
    perdio = rbinom(n, 1, 0.6),
    Profit = ifelse(perdio == 1,
                    -Bet * runif(n, 0.5, 1),
                     Bet * runif(n, 0.3, 2))
  )

write.csv(data_simulado, "datos/processed/casino_simulado.csv", row.names = FALSE)

# Train / test split (80 / 20), stratified
set.seed(123)
trainIndex    <- createDataPartition(data_simulado$perdio, p = 0.8, list = FALSE)
train         <- data_simulado[trainIndex, ]
test          <- data_simulado[-trainIndex, ]

# Model 1: Simple logistic regression
modelo_simple      <- glm(perdio ~ Bet + hora, data = train, family = binomial)
pred_simple        <- predict(modelo_simple, test, type = "response")
pred_clase_simple  <- ifelse(pred_simple > 0.5, 1, 0)

cat("\n=== SIMPLE MODEL ===\n")
confusionMatrix(as.factor(pred_clase_simple), as.factor(test$perdio))

# Model 2: Logistic regression with interaction term
modelo_interacciones <- glm(perdio ~ Bet * hora, data = train, family = binomial)
pred_int             <- predict(modelo_interacciones, test, type = "response")
pred_clase_int       <- ifelse(pred_int > 0.5, 1, 0)

cat("\n=== MODEL WITH INTERACTIONS ===\n")
confusionMatrix(as.factor(pred_clase_int), as.factor(test$perdio))
