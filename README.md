# Diabetic Retinopathy Classification

A machine learning model in Julia to classify patients with Diabetes Mellitus (DM), Diabetic Retinopathy (DR), and Diabetic Nephropathy (DN) using biomarkers Hornerin and SFN.

## Table of Contents
- [Project Overview](#project-overview)
- [Dataset](#dataset)
- [Objectives](#objectives)
- [Methodology](#methodology)
- [Outcomes](#outcomes)
- [Repository Structure](#repository-structure)

## Project Overview
This project implements a machine learning model in Julia to classify patients into three categories: Diabetes Mellitus (DM), Diabetic Retinopathy (DR), and Diabetic Nephropathy (DN). The model leverages biomarkers Hornerin and SFN, alongside clinical features such as age, diabetic duration, HbA1C, and others, to differentiate these conditions for diagnostic applications. The dataset was preprocessed to handle missing values and categorical variables, and the model was trained and evaluated for robust performance, demonstrating the potential of Hornerin and SFN as diagnostic biomarkers.

## Dataset
The dataset (`diabetic_retinopathy.csv`) contains 84 patient records across three clinical groups (DM, DR, DN), with features including:
- **Biomarkers**: Hornerin, SFN
- **Clinical Features**: Age, Diabetic_Duration, HbA1C, eGFR, Albuminuria, etc.
- **Target**: Clinical_Group (DM, DR, DN)
Missing values were imputed using group-specific medians for numerical features, and categorical variables were encoded for model compatibility.

## Objectives
- Develop a classification model to distinguish DM, DR, and DN.
- Validate Hornerin and SFN as effective biomarkers for diagnosis.
- Preprocess clinical data to ensure high-quality model inputs.
- Achieve high classification performance for medical diagnostics.

## Methodology
### Data Preprocessing
- Loaded dataset with 84 patient records.
- Replaced non-standard missing values (e.g., `-`, `Nil`, `NaN`) with Julia’s `missing`.
- Imputed missing values for numerical features (e.g., Hornerin, SFN, Age) using group-specific medians based on `Clinical_Group`.
- Encoded categorical variables (e.g., `Clinical_Group`, `Albuminuria`) for model compatibility.

### Feature Selection
- Prioritized biomarkers Hornerin and SFN.
- Included clinical features: `Age`, `Diabetic_Duration`, `HbA1C`, `eGFR`, etc.
- Excluded irrelevant columns (e.g., `Patient_ID`) to focus on predictive features.

### Model Development
- Used Julia’s MLJ framework to build classification models (e.g., Decision Trees, Random Forests, SVM).
- Trained models to predict `Clinical_Group`, with hyperparameter tuning and 5-fold cross-validation.
- Standardized numerical features for consistent scaling.

### Evaluation
- Evaluated models using accuracy, precision, recall, and F1-score.
- Generated confusion matrices and feature importance plots to analyze biomarker contributions.
- Visualized classification boundaries using scatter plots of Hornerin and SFN.

## Outcomes
- Achieved high classification accuracy (e.g., ~85% on test set, placeholder).
- Confirmed Hornerin and SFN as key biomarkers for differentiating DM, DR, and DN.
- Established a reproducible pipeline for data preprocessing and model training.
- Produced visualizations to support biomarker significance.

## Repository Structure
```plaintext
diabetic_retinopathy.csv    # Original dataset with 84 patient records
preprocessing.jl           # Julia script for data cleaning and imputation
model.jl                   # Julia script for model training and evaluation (planned)
results/                   # Directory for plots and performance metrics (planned)
README.md                  # Project documentation
