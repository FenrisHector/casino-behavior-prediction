# ============================================
# 01 - ANÁLISIS EXPLORATORIO DE DATOS
# Proyecto: Casino Behavior Prediction
# ============================================

# Cargar librerías
library(readr)
library(dplyr)
library(ggplot2)

# Cargar datos
data <- read_csv("datos/raw/bustabit.csv")

# Ver estructura
str(data)
head(data)
summary(data)

# Dimensiones del dataset
cat("Filas:", nrow(data), "\n")
cat("Columnas:", ncol(data), "\n")

# Ver nombres de columnas
colnames(data)

# Valores faltantes
colSums(is.na(data))
