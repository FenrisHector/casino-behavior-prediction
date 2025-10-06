# ============================================
# 02 - PREPARACIÓN Y LIMPIEZA DE DATOS
# ============================================

library(dplyr)
library(lubridate)
library(readr)

# Cargar datos
data <- read_csv("datos/raw/bustabit.csv")

# Limpiar y crear variables
data <- data %>%
  filter(!is.na(Profit)) %>% # Quitar filas sin Profit
  mutate(
    # Convertir fecha
    PlayDate = as.POSIXct(PlayDate, format = "%Y-%m-%d %H:%M:%S"),

    # Variables temporales
    hora = hour(PlayDate),
    dia_semana = wday(PlayDate, label = TRUE),

    # Variable objetivo: perdió
    perdio = ifelse(Profit < 0, 1, 0),

    # Tipo de apuesta
    tipo_apuesta = case_when(
      Bet < 10 ~ "pequeña",
      Bet < 100 ~ "media",
      TRUE ~ "grande"
    )
  )

# Verificar
sum(is.na(data$perdio))

# Guardar
write.csv(data, "datos/processed/bustabit_procesado.csv", row.names = FALSE)
