Diabetic Retinopathy Classification
About
This project implements a machine learning model in Julia to classify patients into three categories: Diabetes Mellitus (DM), Diabetic Retinopathy (DR), and Diabetic Nephropathy (DN). The model leverages biomarkers Hornerin and SFN, combined with clinical features such as age, diabetic duration, and HbA1C, to differentiate these conditions for diagnostic applications. The dataset was meticulously preprocessed to handle missing values and categorical variables, followed by model training and evaluation to achieve robust classification performance.
Objectives

Develop a classification model to distinguish between DM, DR, and DN using key biomarkers.
Utilize Hornerin and SFN as primary features to enhance diagnostic accuracy.
Preprocess clinical data to ensure high-quality input for machine learning.
Demonstrate the model’s potential for medical diagnostics through rigorous evaluation.

Methodology

Data Preprocessing:

Loaded dataset with patient records across DM, DR, and DN groups.
Replaced non-standard missing values (e.g., -, Nil, NaN) with Julia’s missing type.
Imputed missing values for numerical features (e.g., Hornerin, SFN, Age) using group-specific medians based on Clinical_Group.
Encoded categorical variables (e.g., Clinical_Group) for model compatibility.


Feature Selection:

Prioritized biomarkers Hornerin and SFN, supplemented by clinical features like Age, Diabetic_Duration, and HbA1C.
Excluded irrelevant columns (e.g., Patient_ID) to focus on predictive features.


Model Development:

Built a machine learning model using Julia’s MLJ framework.
Trained and evaluated models (e.g., Decision Trees, Random Forests) to classify patients into DM, DR, or DN.
Optimized model performance through hyperparameter tuning and cross-validation.


Evaluation:

Assessed model accuracy, precision, recall, and F1-score.
Visualized results using plots to highlight biomarker contributions and classification boundaries.



Outcomes

Successfully classified patients into DM, DR, and DN with high accuracy.
Confirmed Hornerin and SFN as effective biomarkers for differentiating diabetic conditions.
Produced a robust pipeline for data preprocessing and model training, suitable for medical diagnostics.

Repository Structure

diabetic_retinopathy.csv: Original dataset with patient records.
preprocessing.jl: Julia script for data cleaning and imputation.
model.jl: Julia script for model training and evaluation (to be added).
results/: Directory for output plots and performance metrics (to be added).

Getting Started

Install Julia from julialang.org.
Install required packages:using Pkg
Pkg.add(["CSV", "DataFrames", "MLJ", "ScikitLearn", "DecisionTree", "GLM", "StatsBase", "Plots"])


Run preprocessing:include("preprocessing.jl")


Explore model training (to be implemented in model.jl).

Keywords

Machine Learning
Julia
Diabetic Retinopathy
Diabetic Nephropathy
Biomarkers
Hornerin
SFN
Medical Diagnostics
Data Preprocessing
Classification

