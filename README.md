# Casino Behavior Prediction

Player behavior analysis in online casinos using supervised and unsupervised machine learning techniques in **R**.

## Description

This project focuses on detecting patterns in gambling behavior and predicting the outcomes of online bets.
The main goal was not just to write code, but to explore and clean real-world data, evaluate multiple machine learning models in R, and interpret their results in the context of a game of chance.
Clustering techniques were applied to segment player profiles, while classification and regression models were built to estimate losses, profits, and outcome probabilities.
AI assistance (GitHub Copilot in VS Code) was used minimally for code suggestions and autocompletion; all analytical decisions were made manually.

## Objectives

- Identify distinct player types through clustering analysis
- Estimate the probability of losing a bet
- Predict expected profit using regression models
- Compare performance across multiple predictive models

## Data

**Primary source:** [Bustabit Gambling Behavior Dataset — Kaggle](https://www.kaggle.com/datasets/), a crash-style online casino game

- 50,000 betting records
- 9 main variables: `Id`, `GameID`, `Username`, `Bet`, `Profit`, `BustedAt`, `CashedOut`, `Bonus`, `PlayDate`
- Period: 2023
- Approximate size: 2.3 MB

**Engineered features**

| Variable | Description |
|---|---|
| `hora` | Hour of the day (0–23) |
| `dia_semana` | Day of the week (1–7) |
| `perdio` | 1 if the bet resulted in a loss, 0 if a win |
| `tipo_apuesta` | Bet size category: small / medium / large |

Since the original dataset contained only wins, **5,000 synthetic records** were generated using base R distributions (`rexp`, `sample`, `rbinom`) to simulate a more realistic loss rate (60% losses, 40% wins).

## Methodology

### 1. Exploratory Data Analysis

General overview of the dataset, missing value removal, and descriptive statistics on numerical variables.
Temporal features (`hora`, `dia_semana`) were extracted from the `PlayDate` column.

### 2. Data Preparation

Date parsing to `POSIXct` format, creation of derived variables, and bet size categorization.

### 3. Train / Test Split

- 80% training / 20% test
- Stratified split using `createDataPartition` from `caret`
- Fixed random seed: `set.seed(123)`

### 4. Clustering

- Algorithm: K-Means with k = 3
- Features used: total bets and average bet per player
- Aggregated across 1,182 unique players with at least 5 bets

| Cluster | Players | Avg Bet | Profile |
|---|---|---|---|
| High Risk | 19 (1.6%) | 177,505 | High-stakes, low-frequency gamblers |
| Frequent | 109 (9.2%) | 418 | Regular players with moderate bets |
| Casual | 1,054 (89.2%) | 1,953 | Occasional, low-stakes players |

### 5. Classification Models

Target variable: `perdio` (0 = win, 1 = loss)

| Model | Accuracy | Kappa | Notes |
|---|---|---|---|
| Logistic Regression | 0.585 | 0.00 | Predicts majority class |
| Random Forest | 0.530 | 0.01 | Marginal improvement, low discrimination |

Evaluated with 5-fold cross-validation.

### 6. Regression Models

Target variable: `Profit`

| Model | R² | RMSE | Significant predictors |
|---|---|---|---|
| Simple (Bet + hora) | 0.029 | 136.45 | Bet |
| With interactions (Bet × hora + dia_semana) | 0.019 | 136.26 | Bet, Bet:hora |

`Bet` is the strongest predictor, though explained variance is low — expected in a game of chance.

## Visualizations

Premium-quality charts generated with `ggplot2` and `patchwork` for project documentation:

| File | Description |
|---|---|
| `player_segmentation_kmeans.png` | K-Means scatter plot with labeled cluster centroids (log scale) |
| `bet_distribution_by_profile.png` | Violin + boxplot showing bet distribution per player profile |
| `linear_regression_profit_analysis.png` | Predicted vs actual profit panel + prediction error distribution |

Run `notebooks/07_visualizaciones_linkedin.R` to regenerate all figures.

## Repository Structure

```
casino-behavior-prediction/
├── datos/
│   ├── raw/                  # Raw Bustabit dataset (not tracked by git)
│   └── processed/            # Cleaned and simulated datasets (not tracked by git)
├── notebooks/
│   ├── 01_analisis_exploratorio.R
│   ├── 02_preparacion_datos.R
│   ├── 03_clustering_perfiles.R
│   ├── 04_prediccion_churn.R
│   ├── 05_regresion_lineal.R
│   ├── 06_modelos_avanzados.R
│   └── 07_visualizaciones_linkedin.R
├── results/
│   └── figures/
└── README.md
```

## Tech Stack

- **Language:** R 4.5
- **Libraries:** `dplyr`, `ggplot2`, `caret`, `randomForest`, `lubridate`, `readr`, `scales`, `patchwork`
- **Version control:** Git / GitHub
- **IDE:** Visual Studio Code with R extension

## Setup

Install dependencies:

```r
install.packages(c("dplyr", "ggplot2", "caret", "randomForest",
                   "readr", "lubridate", "scales", "patchwork"))
```

Run scripts in order:

```r
source("notebooks/01_analisis_exploratorio.R")
source("notebooks/02_preparacion_datos.R")
source("notebooks/03_clustering_perfiles.R")
source("notebooks/04_prediccion_churn.R")
source("notebooks/05_regresion_lineal.R")
source("notebooks/06_modelos_avanzados.R")
source("notebooks/07_visualizaciones_linkedin.R")  # premium figures
```

## Conclusions

- Three distinct player profiles were identified through K-Means clustering
- Classification models performed near the baseline, consistent with the inherent randomness of gambling outcomes
- `Bet` amount is the most relevant predictor across all models
- Logistic regression achieved the best mean accuracy (~58.5%) under cross-validation

## Author

Héctor Zamorano García

---

*Fixed seed: 123 · Synthetic dataset generated with exponential and binomial distributions*
