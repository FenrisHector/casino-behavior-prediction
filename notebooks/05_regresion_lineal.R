# ============================================
# 05 - REGRESIÓN LINEAL (Predecir Profit)
# ============================================

library(dplyr)
library(caret)
library(ggplot2)

# Cargar datos simulados
data <- read.csv("datos/processed/casino_simulado.csv")

# Train/Test split (80/20)
set.seed(123)
trainIndex <- createDataPartition(data$Profit, p = 0.8, list = FALSE)
train <- data[trainIndex, ]
test <- data[-trainIndex, ]

# Modelo 1: Regresión lineal simple
modelo_simple <- lm(Profit ~ Bet + hora, data = train)
summary(modelo_simple)

# Modelo 2: Con interacciones
modelo_interacciones <- lm(Profit ~ Bet * hora + dia_semana, data = train)
summary(modelo_interacciones)

# Predicciones en TEST
pred_simple <- predict(modelo_simple, test)
pred_int <- predict(modelo_interacciones, test)

# Métricas (RMSE, R²)
cat("\n=== MODELO SIMPLE ===\n")
cat("RMSE:", RMSE(pred_simple, test$Profit), "\n")
cat("R²:", R2(pred_simple, test$Profit), "\n")

cat("\n=== MODELO CON INTERACCIONES ===\n")
cat("RMSE:", RMSE(pred_int, test$Profit), "\n")
cat("R²:", R2(pred_int, test$Profit), "\n")

# Gráfico: Predicho vs Real
ggplot(
  data.frame(Real = test$Profit, Predicho = pred_int),
  aes(x = Real, y = Predicho)
) +
  geom_point(alpha = 0.5) +
  geom_abline(slope = 1, intercept = 0, color = "red") +
  labs(
    title = "Regresión Lineal: Predicho vs Real",
    x = "Profit Real", y = "Profit Predicho"
  ) +
  theme_minimal()

ggsave("results/figures/regresion_lineal.png", width = 8, height = 6)
