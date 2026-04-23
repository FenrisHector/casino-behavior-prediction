# ============================================
# 03 - CLUSTERING: PLAYER PROFILES (LOG SCALE)
# Project: Casino Behavior Prediction
# ============================================

library(dplyr)
library(ggplot2)
library(scales)

# Load processed data
data <- read.csv("datos/processed/bustabit_procesado.csv")

# Aggregate data per player
jugadores <- data %>%
  group_by(Username) %>%
  summarise(
    apuestas_totales = n(),
    apuesta_promedio = mean(Bet),
    tasa_perdida     = mean(perdio, na.rm = TRUE)
  ) %>%
  filter(apuestas_totales >= 5)   # Keep players with at least 5 bets

# Scale features before clustering
datos_cluster <- jugadores %>%
  select(apuestas_totales, apuesta_promedio) %>%
  scale()

# K-Means with k = 3
set.seed(123)
kmeans_result    <- kmeans(datos_cluster, centers = 3, nstart = 25)
jugadores$cluster <- as.factor(kmeans_result$cluster)

# --- Visualization (log scale) ---
ggplot(jugadores, aes(x = apuesta_promedio, y = apuestas_totales, color = cluster)) +
  geom_point(alpha = 0.6, size = 3) +
  scale_x_log10(labels = scales::comma) +
  labs(
    title = "Player Profiles (Logarithmic Scale)",
    x     = "Average Bet (Log Scale)",
    y     = "Number of Bets",
    color = "Cluster"
  ) +
  theme_minimal()

# Save figure
ggsave("results/figures/clusters_perfiles_log.png", width = 9, height = 6)
