# WeatherAUS Rainfall Prediction Project

**Language:** R  
**Libraries:** `tidyverse`, `GGally`, `caret`, `rpart`, `rpart.plot`, `knitr`, `formatR`  
**Dataset:** Australian Weather Dataset (Kaggle) — daily weather observations (Nov 2007–Jun 2017)  
**Group Project:** Completed as part of a collaborative team effort.

---

## Objective

- Explore how well we can predict:
  1. **Amount of rainfall** on a given day
  2. **Whether it will rain tomorrow**

---

## Data Description

- Covers daily weather observations across Australia  
- Variables include **temperature, rainfall, wind, pressure, humidity**, and more  
- **Targets:**  
  - `Rainfall` (numeric)  
  - `RainTomorrow` (binary, Yes = 1, No = 0)  
- **Predictors:** Humidity9am, RainToday, WindDir9am, MaxTemp, Location, Pressure9am, Sunshine, Evaporation, etc.  
- Data provides rich context to explore weather patterns and predict rainfall  

**Data cleaning and preparation steps:**
1. Removed missing values (`NA`)
2. Converted `RainToday` and `RainTomorrow` from “Yes/No” to binary (1/0)
3. Standardized numeric variables for modeling
4. Stratified training and test sets for classification tasks

---

## Exploratory Data Analysis

- Visualized relationships using **GGpairs**.
- Key observations:
  - High humidity → higher rainfall
  - Pressure9am trends align with rainfall patterns

*Visuals: GGpairs plots showing Humidity9am, Pressure9am, Rainfall, etc.*

---

## Part 1: Predicting Rainfall Amount

**Goal:** Can we predict the amount of rain using morning weather conditions?

- **Simple Linear Regression:**
  - Predictor: Humidity9am
  - Observations: Positive relationship; higher humidity → more rainfall, but spread shows Humidity alone is insufficient
- **Multiple Linear Regression (log-transformed Rainfall):**
  - Predictors: Humidity9am, MaxTemp, Sunshine, Evaporation
  - Observations: Log transform improves model fit; higher rainfall days better captured
- **Regression Tree:**
  - Predictors: Multiple weather variables
  - Observations: More sunshine → less rain; higher humidity → more rain
- **RMSE Comparison:**
  - Log-linear regression had lowest RMSE → best predictive accuracy

*Visuals: Scatterplots of regression models, Regression Tree diagram*

---

## Part 2: Predicting Rain Tomorrow

**Goal:** Can we predict whether it will rain tomorrow?

- **Data Preparation:**
  - Converted `RainToday` and `RainTomorrow` to binary (Yes=1, No=0)
  - Standardized numeric variables
  - Stratified training and test sets for balanced outcomes
- **K-Nearest Neighbors (KNN):**
  - Accuracy: 76%
  - Observations: Model predicts no rain more accurately than rain
- **Classification Tree:**
  - Observations:
    - More sunshine → likely no rain tomorrow
    - Higher rainfall today → likely rain tomorrow
  - Model selected key predictors: Sunshine, Pressure, Rainfall today
  - Slightly lower accuracy than KNN but interpretable

*Visuals: Confusion matrix for KNN, Pruned classification tree diagram*

---

## Key Findings

- **Rainfall Amount:**
  - Log-linear regression captures spread better than simple linear regression
  - Low temperature + high humidity → highest rainfall
- **Rain Tomorrow:**
  - KNN accuracy = 76%
  - Best predictors: Sunshine, Pressure, Rainfall today
  - More sunshine and less rain today → less chance of rain tomorrow
- **Decision Tree Insights:**
  - Provides clear rules for rain vs. no rain
  - Slightly lower accuracy than KNN but easy to interpret

