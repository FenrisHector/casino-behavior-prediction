# ============================================
# 03 - CLUSTERING: PERFILES DE JUGADORES
# ============================================

library(dplyr)
library(ggplot2)

# Cargar datos procesados
data <- read.csv("datos/processed/bustabit_procesado.csv")

# Crear dataset de jugadores
jugadores <- data %>%
  group_by(Username) %>%
  summarise(
    apuestas_totales = n(),
    apuesta_promedio = mean(Bet),
    tasa_perdida = mean(perdio, na.rm = TRUE)
  ) %>%
  filter(apuestas_totales >= 5)

# Clustering (sin tasa_perdida porque es constante)
datos_cluster <- jugadores %>%
  select(apuestas_totales, apuesta_promedio) %>%
  scale()

set.seed(123)
kmeans_result <- kmeans(datos_cluster, centers = 3, nstart = 25)

jugadores$cluster <- as.factor(kmeans_result$cluster)

# Resumen por cluster
jugadores %>%
  group_by(cluster) %>%
  summarise(
    n = n(),
    apuesta_prom = mean(apuesta_promedio),
    apuestas_tot = mean(apuestas_totales)
  )

# Visualización
ggplot(jugadores, aes(x = apuesta_promedio, y = apuestas_totales, color = cluster)) +
  geom_point(alpha = 0.6, size = 3) +
  labs(
    title = "Perfiles de Jugadores",
    x = "Apuesta Promedio",
    y = "Número de Apuestas"
  ) +
  theme_minimal()

ggsave("results/figures/clusters_perfiles.png", width = 8, height = 6)
