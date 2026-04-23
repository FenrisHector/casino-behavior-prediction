# ============================================
# 02 - DATA PREPARATION AND CLEANING
# Project: Casino Behavior Prediction
# ============================================

library(dplyr)
library(lubridate)
library(readr)

# Load raw data
data <- read_csv("datos/raw/bustabit.csv")

# Clean and engineer features
data <- data %>%
  filter(!is.na(Profit)) %>%       # Remove rows with missing Profit
  mutate(
    # Parse datetime
    PlayDate = as.POSIXct(PlayDate, format = "%Y-%m-%d %H:%M:%S"),

    # Time-based features
    hora       = hour(PlayDate),
    dia_semana = wday(PlayDate, label = TRUE),

    # Target variable: 1 if the bet resulted in a loss
    perdio = ifelse(Profit < 0, 1, 0),

    # Bet size category
    tipo_apuesta = case_when(
      Bet < 10  ~ "pequeña",
      Bet < 100 ~ "media",
      TRUE      ~ "grande"
    )
  )

# Sanity check: no NAs in target
sum(is.na(data$perdio))

# Save processed dataset
write.csv(data, "datos/processed/bustabit_procesado.csv", row.names = FALSE)
