# ============================================
# 06 - VALIDACIÓN CRUZADA Y COMPARACIÓN
# ============================================

library(caret)
library(randomForest)

# Cargar datos
data <- read.csv("datos/processed/casino_simulado.csv")
data$perdio <- as.factor(data$perdio)

# Configurar validación cruzada 5-fold
control <- trainControl(method = "cv", number = 5)

# Modelo 1: Regresión Logística
set.seed(123)
modelo_logit <- train(perdio ~ Bet + hora,
  data = data,
  method = "glm",
  family = "binomial",
  trControl = control
)

# Modelo 2: Random Forest
set.seed(123)
modelo_rf <- train(perdio ~ Bet + hora + dia_semana,
  data = data,
  method = "rf",
  trControl = control
)

# Comparar modelos
resultados <- resamples(list(
  Logistica = modelo_logit,
  RandomForest = modelo_rf
))

summary(resultados)

# Gráfico comparativo
png("results/figures/comparacion_modelos.png", width = 800, height = 600)
bwplot(resultados)
dev.off()

# Mejores modelos
cat("\n=== MEJOR MODELO ===\n")
cat("Regresión Logística - Accuracy:", max(modelo_logit$results$Accuracy), "\n")
cat("Random Forest - Accuracy:", max(modelo_rf$results$Accuracy), "\n")
