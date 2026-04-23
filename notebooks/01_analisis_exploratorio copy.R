# ============================================
# 01 - EXPLORATORY DATA ANALYSIS
# Project: Casino Behavior Prediction
# ============================================

# Load libraries
library(readr)
library(dplyr)
library(ggplot2)

# Load raw data
data <- read_csv("datos/raw/bustabit.csv")

# Inspect structure
str(data)
head(data)
summary(data)

# Dataset dimensions
cat("Rows:", nrow(data), "\n")
cat("Columns:", ncol(data), "\n")

# Column names
colnames(data)

# Missing values per column
colSums(is.na(data))
