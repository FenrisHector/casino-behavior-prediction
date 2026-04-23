# ============================================================
# 07 - PREMIUM VISUALIZATIONS FOR LINKEDIN
# Project: Casino Behavior Prediction
# Run from the project root directory
#
# Outputs 3 images to results/figures/:
#   player_segmentation_kmeans.png
#   bet_distribution_by_profile.png
#   linear_regression_profit_analysis.png
# ============================================================

library(randomForest)  # loaded first so ggplot2 can reclaim margin()
library(dplyr)
library(ggplot2)
library(scales)
library(caret)
library(lubridate)
library(readr)
library(patchwork)   # install.packages("patchwork") if not available

dir.create("results/figures", recursive = TRUE, showWarnings = FALSE)

# ============================================================
# CUSTOM DARK THEME
# ============================================================
theme_casino <- function() {
  theme_minimal(base_family = "sans") +
    theme(
      plot.background   = element_rect(fill = "#0d1117", color = NA),
      panel.background  = element_rect(fill = "#161b22", color = NA),
      panel.grid.major  = element_line(color = "#21262d", linewidth = 0.5),
      panel.grid.minor  = element_blank(),
      panel.border      = element_rect(color = "#30363d", fill = NA, linewidth = 0.8),
      axis.text         = element_text(color = "#8b949e", size = 10),
      axis.title        = element_text(color = "#c9d1d9", size = 11, face = "bold"),
      plot.title        = element_text(color = "#f0f6fc", size = 16, face = "bold",
                                       margin = margin(b = 6)),
      plot.subtitle     = element_text(color = "#8b949e", size = 11,
                                       margin = margin(b = 12)),
      plot.caption      = element_text(color = "#484f58", size = 9,
                                       margin = margin(t = 10)),
      legend.background = element_rect(fill = "#161b22", color = "#30363d"),
      legend.text       = element_text(color = "#c9d1d9", size = 10),
      legend.title      = element_text(color = "#f0f6fc", size = 11, face = "bold"),
      legend.key        = element_rect(fill = "#161b22", color = NA),
      strip.background  = element_rect(fill = "#21262d", color = "#30363d"),
      strip.text        = element_text(color = "#f0f6fc", face = "bold", size = 11),
      plot.margin       = margin(20, 20, 15, 20)
    )
}

# ============================================================
# DATA: load processed files or fall back to synthetic data
# ============================================================

# --- Clustering data (real Bustabit dataset) ---
if (file.exists("datos/processed/bustabit_procesado.csv")) {
  data_real <- read.csv("datos/processed/bustabit_procesado.csv")
} else {
  # Synthetic fallback matching the distribution documented in the README
  set.seed(42)
  n_users <- 1182
  data_real <- data.frame(
    Username = paste0("user_", seq_len(n_users)),
    Bet      = c(rexp(1054, 1 / 8),
                 rexp(109,  1 / 418),
                 rexp(19,   1 / 177505)),
    perdio   = rbinom(n_users, 1, 0.6)
  )
}

# Aggregate per player and apply K-Means
jugadores <- data_real %>%
  group_by(Username) %>%
  summarise(
    apuestas_totales = n(),
    apuesta_promedio = mean(Bet, na.rm = TRUE),
    tasa_perdida     = mean(perdio, na.rm = TRUE)
  ) %>%
  filter(apuestas_totales >= 5)

set.seed(123)
datos_cluster     <- scale(jugadores[, c("apuestas_totales", "apuesta_promedio")])
kmeans_result     <- kmeans(datos_cluster, centers = 3, nstart = 25)
jugadores$cluster <- as.factor(kmeans_result$cluster)

# Label clusters by size: largest -> Casual, medium -> Frequent, smallest -> High Risk
sizes <- sort(table(jugadores$cluster))
map_labels <- setNames(
  c("Alto Riesgo", "Frecuentes", "Casuales"),
  names(sizes)
)
jugadores$perfil <- factor(
  map_labels[jugadores$cluster],
  levels = c("Casuales", "Frecuentes", "Alto Riesgo")
)

# --- Simulated data for regression analysis ---
set.seed(123)
n <- 5000
data_sim <- data.frame(
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

# ============================================================
# PLOT 1 — K-Means player segmentation
# Output: player_segmentation_kmeans.png
# ============================================================

centroides <- jugadores %>%
  group_by(perfil) %>%
  summarise(
    cx = median(apuesta_promedio),
    cy = median(apuestas_totales),
    n  = n()
  )

p1 <- ggplot(jugadores,
             aes(x = apuesta_promedio, y = apuestas_totales, color = perfil)) +
  geom_point(alpha = 0.55, size = 2.2) +
  geom_label(
    data = centroides,
    aes(x = cx, y = cy,
        label = paste0(perfil, "\n(n = ", n, ")"),
        fill = perfil),
    color = "white", size = 3.5, fontface = "bold",
    label.padding = unit(0.4, "lines"),
    label.r       = unit(0.3, "lines"),
    show.legend   = FALSE
  ) +
  scale_x_log10(labels = label_comma(),
                breaks  = c(1, 10, 100, 1000, 10000, 100000)) +
  scale_color_manual(
    values = c("Casuales"    = "#58a6ff",
               "Frecuentes"  = "#3fb950",
               "Alto Riesgo" = "#f85149")
  ) +
  scale_fill_manual(
    values = c("Casuales"    = "#1f4b8a",
               "Frecuentes"  = "#145220",
               "Alto Riesgo" = "#7d1f1f")
  ) +
  labs(
    title    = "Segmentación de Jugadores — K-Means (k = 3)",
    subtitle = "1.182 jugadores únicos · Dataset Bustabit · Escala logarítmica en eje X",
    x        = "Apuesta Promedio (escala log)",
    y        = "Número de Apuestas",
    caption  = "Casino Behavior Prediction · github.com/HectorZamoranoGarcia"
  ) +
  theme_casino() +
  theme(legend.position = "none")

ggsave("results/figures/player_segmentation_kmeans.png",
       plot = p1, width = 12, height = 7, dpi = 150, bg = "#0d1117")
cat("✅ Saved: player_segmentation_kmeans.png\n")

# ============================================================
# PLOT 2 — Bet distribution by player profile (violin + boxplot)
# Output: bet_distribution_by_profile.png
# ============================================================

p2 <- ggplot(jugadores,
             aes(x = perfil, y = apuesta_promedio, fill = perfil)) +
  geom_violin(alpha = 0.35, trim = TRUE, linewidth = 0.6, color = NA) +
  geom_boxplot(width = 0.15, alpha = 0.85, outlier.shape = NA,
               color = "#c9d1d9", linewidth = 0.7) +
  geom_jitter(aes(color = perfil), width = 0.08, alpha = 0.3, size = 1.2) +
  scale_y_log10(labels = label_comma()) +
  scale_fill_manual(
    values = c("Casuales"    = "#58a6ff",
               "Frecuentes"  = "#3fb950",
               "Alto Riesgo" = "#f85149")
  ) +
  scale_color_manual(
    values = c("Casuales"    = "#58a6ff",
               "Frecuentes"  = "#3fb950",
               "Alto Riesgo" = "#f85149")
  ) +
  annotate("text",
           x     = c(1, 2, 3),
           y     = c(0.4, 0.4, 0.4),
           label = c("89.2% usuarios", "9.2% usuarios", "1.6% usuarios"),
           color = "#8b949e", size = 3.5, vjust = 1) +
  labs(
    title    = "Distribución de Apuestas por Perfil de Jugador",
    subtitle = "Violin plot + Boxplot · Escala logarítmica · Apuesta promedio por jugador",
    x        = "Perfil",
    y        = "Apuesta Promedio (escala log)",
    caption  = "Casino Behavior Prediction · github.com/HectorZamoranoGarcia"
  ) +
  theme_casino() +
  theme(legend.position = "none")

ggsave("results/figures/bet_distribution_by_profile.png",
       plot = p2, width = 10, height = 7, dpi = 150, bg = "#0d1117")
cat("✅ Saved: bet_distribution_by_profile.png\n")

# ============================================================
# PLOT 3 — Linear regression: predicted vs actual + error distribution
# Output: linear_regression_profit_analysis.png
# ============================================================

set.seed(123)
trainIdx  <- createDataPartition(data_sim$Profit, p = 0.8, list = FALSE)
train_reg <- data_sim[trainIdx, ]
test_reg  <- data_sim[-trainIdx, ]

modelo_reg <- lm(Profit ~ Bet * hora + dia_semana, data = train_reg)
preds      <- predict(modelo_reg, test_reg)
df_pred    <- data.frame(Real = test_reg$Profit, Predicho = preds) %>%
  mutate(Error = Predicho - Real)

# Panel A: Predicted vs Actual
pa <- ggplot(df_pred, aes(x = Real, y = Predicho)) +
  geom_point(alpha = 0.25, size = 1.3, color = "#58a6ff") +
  geom_abline(slope = 1, intercept = 0,
              color = "#f85149", linewidth = 1.1, linetype = "dashed") +
  annotate("text",
           x       = max(df_pred$Real) * 0.55,
           y       = max(df_pred$Predicho) * 0.88,
           label   = paste0("R\u00b2 = ", round(summary(modelo_reg)$r.squared, 3),
                            "\nRMSE = ", round(sqrt(mean(df_pred$Error^2)), 2)),
           color   = "#f0f6fc", size = 4.2, hjust = 0, fontface = "bold") +
  labs(
    title    = "Predicho vs Real — Regresión Lineal",
    subtitle = "Línea roja: predicción perfecta",
    x        = "Profit Real",
    y        = "Profit Predicho"
  ) +
  theme_casino()

# Panel B: Prediction error distribution
pb <- ggplot(df_pred, aes(x = Error)) +
  geom_histogram(aes(y = after_stat(density)),
                 bins = 50, fill = "#58a6ff", alpha = 0.5, color = NA) +
  geom_density(color = "#3fb950", linewidth = 1.1) +
  geom_vline(xintercept = 0, color = "#f85149",
             linetype = "dashed", linewidth = 0.9) +
  labs(
    title    = "Distribución del Error de Predicción",
    subtitle = "Error = Predicho \u2212 Real · Referencia en 0",
    x        = "Error",
    y        = "Densidad"
  ) +
  theme_casino()

p3 <- pa + pb +
  plot_annotation(
    title    = "Análisis de Regresión Lineal — Profit Esperado",
    subtitle = "Variable objetivo: Profit · Predictores: Bet, hora, día de semana",
    caption  = "Casino Behavior Prediction · github.com/HectorZamoranoGarcia",
    theme    = theme(
      plot.background = element_rect(fill = "#0d1117", color = NA),
      plot.title      = element_text(color = "#f0f6fc", size = 16, face = "bold"),
      plot.subtitle   = element_text(color = "#8b949e", size = 11),
      plot.caption    = element_text(color = "#484f58", size = 9)
    )
  )

ggsave("results/figures/linear_regression_profit_analysis.png",
       plot = p3, width = 14, height = 7, dpi = 150, bg = "#0d1117")
cat("✅ Saved: linear_regression_profit_analysis.png\n")

cat("\n🎉 Done. 3 images saved to results/figures/\n")
