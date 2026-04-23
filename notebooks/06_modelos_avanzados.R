# ============================================
# 06 - CROSS-VALIDATION AND MODEL COMPARISON
# Project: Casino Behavior Prediction
# ============================================

library(caret)
library(randomForest)

# Load simulated data
data        <- read.csv("datos/processed/casino_simulado.csv")
data$perdio <- as.factor(data$perdio)

# 5-fold cross-validation setup
control <- trainControl(method = "cv", number = 5)

# Model 1: Logistic Regression
set.seed(123)
modelo_logit <- train(
  perdio ~ Bet + hora,
  data      = data,
  method    = "glm",
  family    = "binomial",
  trControl = control
)

# Model 2: Random Forest (500 trees)
set.seed(123)
modelo_rf <- train(
  perdio ~ Bet + hora + dia_semana,
  data      = data,
  method    = "rf",
  trControl = control
)

# Compare models
resultados <- resamples(list(
  Logistica    = modelo_logit,
  RandomForest = modelo_rf
))

summary(resultados)

# Comparison boxplot
png("results/figures/comparacion_modelos.png", width = 800, height = 600)
bwplot(resultados)
dev.off()

# Best model summary
cat("\n=== BEST MODEL ===\n")
cat("Logistic Regression - Accuracy:", max(modelo_logit$results$Accuracy), "\n")
cat("Random Forest       - Accuracy:", max(modelo_rf$results$Accuracy),    "\n")
