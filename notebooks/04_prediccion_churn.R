# ============================================
# 04 - PREDICCIÓN CON REGRESIÓN LOGÍSTICA
# ============================================

library(dplyr)
library(caret)

# Simular datos de casino (el dataset real no tenía pérdidas)
set.seed(123)
n <- 5000

data_simulado <- data.frame(
  Bet = rexp(n, 1 / 100),
  hora = sample(0:23, n, replace = TRUE),
  dia_semana = sample(1:7, n, replace = TRUE)
) %>%
  mutate(
    perdio = rbinom(n, 1, 0.6),
    Profit = ifelse(perdio == 1, -Bet * runif(n, 0.5, 1), Bet * runif(n, 0.3, 2))
  )

write.csv(data_simulado, "datos/processed/casino_simulado.csv", row.names = FALSE)

# Train/Test split (80/20)
set.seed(123)
trainIndex <- createDataPartition(data_simulado$perdio, p = 0.8, list = FALSE)
train <- data_simulado[trainIndex, ]
test <- data_simulado[-trainIndex, ]

# Modelo 1: Regresión simple
modelo_simple <- glm(perdio ~ Bet + hora, data = train, family = binomial)
pred_simple <- predict(modelo_simple, test, type = "response")
pred_clase_simple <- ifelse(pred_simple > 0.5, 1, 0)

cat("\n=== MODELO SIMPLE ===\n")
confusionMatrix(as.factor(pred_clase_simple), as.factor(test$perdio))

# Modelo 2: Con interacciones
modelo_interacciones <- glm(perdio ~ Bet * hora, data = train, family = binomial)
pred_int <- predict(modelo_interacciones, test, type = "response")
pred_clase_int <- ifelse(pred_int > 0.5, 1, 0)

cat("\n=== MODELO CON INTERACCIONES ===\n")
confusionMatrix(as.factor(pred_clase_int), as.factor(test$perdio))
