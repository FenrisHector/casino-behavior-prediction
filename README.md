# Casino Behavior Prediction

Proyecto de análisis de comportamiento de jugadores en casinos online usando distintos enfoques de machine learning (supervisado y no supervisado) en **R**

## Descripción

Este proyecto busca detectar patrones en el comportamiento de jugadores y predecir resultados de apuestas online
El enfoque principal no fue únicamente escribir código, sino explorar y limpiar datos, probar distintos modelos de machine learning en R y analizar sus resultados
Se aplicaron técnicas de clustering para segmentar perfiles de usuario y modelos de clasificación y regresión para estimar pérdidas, ganancias y probabilidades de resultado
Durante el desarrollo se utilizó de forma sutil asistencia de inteligencia artificial, principalmente Copilot en Visual Studio Code, para sugerencias y autocompletado de código, pero todas las decisiones y análisis fueron realizados manualmente

## Objetivos

* Identificar distintos tipos de jugadores mediante análisis de clustering
* Estimar la probabilidad de pérdida en una apuesta
* Calcular beneficios esperados con modelos de regresión
* Comparar el rendimiento entre varios modelos predictivos

## Datos

**Fuente principal:** Bustabit Gambling Behavior Dataset (Kaggle)

* 50 000 registros de apuestas
* 9 variables principales (Id, GameID, Username, Bet, Profit, etc)
* Periodo 2023
* Tamaño aproximado 2.3 MB

**Variables creadas**

* `hora`: hora del día (0–23)
* `dia_semana`: día de la semana (1–7)
* `perdio`: 1 si la apuesta resultó en pérdida, 0 si fue ganancia
* `tipo_apuesta`: pequeña / media / grande según el monto

Para equilibrar los datos (el dataset original solo tenía ganancias) se generaron 5 000 registros sintéticos con una distribución más realista (60 % pérdidas y 40 % ganancias) usando funciones base de R (rexp, sample, rbinom)

## Metodología

### 1. Análisis exploratorio

Revisión general del dataset, limpieza de valores faltantes y análisis descriptivo de las variables numéricas
Extracción de información temporal como hora y día desde la variable PlayDate

### 2. Preparación de datos

Conversión de fechas a formato POSIXct
Creación de variables derivadas y categorización de apuestas por monto

### 3. Partición

Conjunto de entrenamiento 80 %
Conjunto de prueba 20 %
Partición estratificada con createDataPartition de caret
Semilla aleatoria 123

### 4. Clustering

Algoritmo K-means con k = 3
Variables utilizadas apuesta total y promedio por jugador
Datos agregados por usuario (1 182 jugadores únicos con al menos 5 apuestas)

| Cluster | Nº Jugadores  | Promedio Apuesta | Interpretación           |
| ------- | ------------- | ---------------- | ------------------------ |
| 1       | 19 (1.6%)     | 177 505          | Jugadores de alto riesgo |
| 2       | 109 (9.2%)    | 418              | Usuarios frecuentes      |
| 3       | 1 054 (89.2%) | 1 953            | Jugadores casuales       |

### 5. Modelos de clasificación

Variable objetivo perdio (0 = ganó, 1 = perdió)
Modelos probados

* Regresión logística simple y con interacción
* Random Forest (ntree = 500)

Resultados de validación cruzada (5-fold)

| Modelo        | Accuracy | Kappa | Observaciones                         |
| ------------- | -------- | ----- | ------------------------------------- |
| Logística     | 0.585    | 0.00  | Predice la clase mayoritaria          |
| Random Forest | 0.530    | 0.01  | Ligera mejora con poca discriminación |

### 6. Modelos de regresión

Variable objetivo Profit

Modelos

* Lineal simple Profit ~ Bet + hora
* Lineal con interacción Profit ~ Bet * hora + dia_semana

| Modelo            | R²    | RMSE   | Variables significativas |
| ----------------- | ----- | ------ | ------------------------ |
| Simple            | 0.029 | 136.45 | Bet                      |
| Con interacciones | 0.019 | 136.26 | Bet, Bet:hora            |

La variable Bet es el mejor predictor, aunque la varianza explicada es baja, lo que tiene sentido en un contexto de azar

## Conclusiones

Se identificaron tres perfiles de jugadores con comportamientos distintos
Los modelos de clasificación tienen un rendimiento limitado, coherente con la naturaleza aleatoria de los juegos de azar
El monto apostado (Bet) es la variable más relevante
La regresión logística fue el modelo con mejor precisión media (≈ 0.58)

## Estructura del repositorio

```
casino-behavior-prediction/
├── datos/
│   ├── raw/
│   └── processed/
├── notebooks/
│   ├── 01_analisis_exploratorio.R
│   ├── 02_preparacion_datos.R
│   ├── 03_clustering_perfiles.R
│   ├── 04_prediccion_churn.R
│   ├── 05_regresion_lineal.R
│   └── 06_modelos_avanzados.R
├── results/
│   └── figures/
└── README.md
```

## Tecnologías

* Lenguaje R 4.5
* Librerías dplyr, ggplot2, caret, randomForest, lubridate, readr
* Control de versiones Git / GitHub
* IDE Visual Studio Code con extensión de R

## Ejecución

Instalar dependencias

```r
install.packages(c("dplyr", "ggplot2", "caret", "randomForest", "readr", "lubridate"))
```

Ejecutar scripts en orden

```r
source("notebooks/01_analisis_exploratorio.R")
source("notebooks/02_preparacion_datos.R")
source("notebooks/03_clustering_perfiles.R")
source("notebooks/04_prediccion_churn.R")
source("notebooks/05_regresion_lineal.R")
source("notebooks/06_modelos_avanzados.R")
```

## Autor

Héctor Zamorano García

Semilla fija 123
Dataset sintético generado con distribuciones exponenciales y binomiales
