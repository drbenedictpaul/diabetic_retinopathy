using MLJ  # For data splitting
using DataFrames
using StatsBase  # For class distribution
using CSV
using Statistics

data = CSV.read("diabetic_retinopathy_preprocessed.csv", DataFrame)

# Separate features (X) and target (y)
y = data[!, :Clinical_Group]  # Target variable
X = select(data, Not(:Clinical_Group))  # Features

# Coerce Clinical_Group to Finite type
y = coerce(y, Finite)

# Split data into training and testing sets (80% train, 20% test)
train_idx, test_idx = partition(1:nrow(data), 0.8, stratify=y, shuffle=true, rng=123)

# Create training and testing DataFrames
X_train = X[train_idx, :]
X_test = X[test_idx, :]
y_train = y[train_idx]
y_test = y[test_idx]

# Verify the split
# println("Training set rows: ", nrow(X_train))
# println("Testing set rows: ", nrow(X_test))
# println("Training class distribution: ", countmap(y_train))
# println("Testing class distribution: ", countmap(y_test))

# using DataFrames
# using Statistics

# Identify numerical columns (all except Clinical_Group and possibly Gender, Albuminuria)
numerical_cols = [col for col in names(X_train) if eltype(X_train[!, col]) <: Union{Missing, Real}]

# Standardize numerical features
for col in numerical_cols
    # Calculate mean and std from training set
    train_mean = mean(skipmissing(X_train[!, col]))
    train_std = std(skipmissing(X_train[!, col]))

    # Avoid division by zero in case of zero std
    if train_std == 0
        train_std = 1.0
    end

    # Standardize training set
    X_train[!, col] = (X_train[!, col] .- train_mean) ./ train_std

    # Standardize test set using training set statistics
    X_test[!, col] = (X_test[!, col] .- train_mean) ./ train_std
end

# Verify scaling for a few columns
for col in [:Hornerin, :SFN, :Age]
    train_mean = mean(skipmissing(X_train[!, col]))
    train_std = std(skipmissing(X_train[!, col]))
    println("Training $col mean: ", round(train_mean, digits=3), ", std: ", round(train_std, digits=3))
end
# println(first(X_train, 5))  # View first 5 rows of scaled X_train

using MLJ
using MLJBase
using DataFrames
using DecisionTree  # For impurity_importance
using Random
using Statistics  # For mean

# Load Random Forest Classifier
RandomForestClassifier = @load RandomForestClassifier pkg=DecisionTree verbosity=0
model = RandomForestClassifier(n_trees=100, max_depth=5, rng=123)

# Create a machine (model + data)
mach = machine(model, X_train, y_train)

# Train the model
MLJ.fit!(mach)

# Make predictions on the test set
y_pred = MLJ.predict_mode(mach, X_test)

# Evaluate accuracy
accuracy = mean(y_pred .== y_test)
println("Test set accuracy: ", round(accuracy, digits=3))

# Compute confusion matrix
confusion = confusion_matrix(y_pred, y_test)
println("Confusion Matrix:\n", confusion)

# Compute feature importance
fit_results = fitted_params(mach)
forest = fit_results.forest
importance = impurity_importance(forest)
feature_importance = sort(collect(zip(names(X_train), importance)), by=x->x[2], rev=true)
println("Top 5 Feature Importances:")
for (feature, importance) in feature_importance[1:5]
    println("$feature: ", round(importance, digits=3))
end

using MLJ
using MLJBase
using DataFrames
using DecisionTree  # For impurity_importance
using Random
using Statistics  # For mean and std
using StatisticalMeasures  # For measures
using Plots  # For plotting

# Load Random Forest Classifier
RandomForestClassifier = @load RandomForestClassifier pkg=DecisionTree verbosity=0
model = RandomForestClassifier(n_trees=100, max_depth=5, rng=123)

# Create a machine with full dataset (X, y)
X = DataFrames.select(data, Not(:Clinical_Group))
y = coerce(data[!, :Clinical_Group], Finite)
mach = machine(model, X, y)

# Define measures
acc = StatisticalMeasures.accuracy
prec = StatisticalMeasures.multiclass_precision
rec = StatisticalMeasures.multiclass_recall
f1 = StatisticalMeasures.multiclass_f1score

# Perform 5-fold cross-validation
cv = CV(nfolds=5, rng=123)
eval_results = evaluate!(mach, resampling=cv, measures=[acc, prec, rec, f1])

# Extract per-fold measurements
acc_per_fold = eval_results.per_fold[1]
prec_per_fold = eval_results.per_fold[2]
rec_per_fold = eval_results.per_fold[3]
f1_per_fold = eval_results.per_fold[4]

# Print cross-validation results
println("5-Fold CV Accuracy: ", round(mean(acc_per_fold), digits=3), " ± ", round(std(acc_per_fold), digits=3))
println("5-Fold CV Precision: ", round(mean(prec_per_fold), digits=3))
println("5-Fold CV Recall: ", round(mean(rec_per_fold), digits=3))
println("5-Fold CV F1-Score: ", round(mean(f1_per_fold), digits=3))

# Save CV results to CSV
cv_results = DataFrame(
    Fold = 1:5,
    Accuracy = acc_per_fold,
    Precision = prec_per_fold,
    Recall = rec_per_fold,
    F1_Score = f1_per_fold
)
CSV.write("cv_results.csv", cv_results)

# Train model on full dataset for feature importance
MLJ.fit!(mach)

# Compute feature importance
fit_results = fitted_params(mach)
forest = fit_results.forest
importance = impurity_importance(forest)
feature_importance = sort(collect(zip(names(X), importance)), by=x->x[2], rev=true)
println("Top 5 Feature Importances:")
for (feature, importance) in feature_importance[1:5]
    println("$feature: ", round(importance, digits=3))
end

# Save feature importance to CSV
importance_df = DataFrame(Feature = names(X), Importance = importance)
CSV.write("feature_importance.csv", importance_df)

# Plot feature importance
top_n = 10  # Plot top 10 features
top_features = first(feature_importance, top_n)
features = [f[1] for f in top_features]
importances = [f[2] for f in top_features]
bar(features, importances, title="Top $top_n Feature Importances", xlabel="Feature", ylabel="Importance", legend=false, size=(800, 400), rotation=45)
savefig("feature_importance_plot.png")

# using MLJ
# using MLJBase
# using DataFrames
# using DecisionTree  # For impurity_importance
# using Random
# using Statistics  # For mean and std
using StatisticalMeasures  # For measures
using Plots  # For plotting
# using CSV  # For saving results
using HypothesisTests  # For Kruskal-Wallis test

# Load Random Forest Classifier
RandomForestClassifier = @load RandomForestClassifier pkg=DecisionTree verbosity=0
model = RandomForestClassifier(n_trees=100, max_depth=5, rng=123)

# Create a machine with full dataset (X, y)
X = DataFrames.select(data, Not(:Clinical_Group))
y = coerce(data[!, :Clinical_Group], Finite)
mach = machine(model, X, y)

# Define measures
acc = StatisticalMeasures.accuracy
prec = StatisticalMeasures.multiclass_precision
rec = StatisticalMeasures.multiclass_recall
f1 = StatisticalMeasures.multiclass_f1score

# Perform 5-fold cross-validation
cv = CV(nfolds=5, rng=123)
eval_results = evaluate!(mach, resampling=cv, measures=[acc, prec, rec, f1])

# Extract per-fold measurements
acc_per_fold = eval_results.per_fold[1]
prec_per_fold = eval_results.per_fold[2]
rec_per_fold = eval_results.per_fold[3]
f1_per_fold = eval_results.per_fold[4]

# Print cross-validation results
println("5-Fold CV Accuracy: ", round(mean(acc_per_fold), digits=3), " ± ", round(std(acc_per_fold), digits=3))
println("5-Fold CV Precision: ", round(mean(prec_per_fold), digits=3))
println("5-Fold CV Recall: ", round(mean(rec_per_fold), digits=3))
println("5-Fold CV F1-Score: ", round(mean(f1_per_fold), digits=3))

# Save CV results to CSV
cv_results = DataFrame(
    Fold = 1:5,
    Accuracy = acc_per_fold,
    Precision = prec_per_fold,
    Recall = rec_per_fold,
    F1_Score = f1_per_fold
)
CSV.write("cv_results.csv", cv_results)
println("Saved CV results to cv_results.csv")

# Train model on full dataset for feature importance
MLJ.fit!(mach)

# Compute feature importance
fit_results = fitted_params(mach)
forest = fit_results.forest
importance = impurity_importance(forest)
feature_importance = sort(collect(zip(names(X), importance)), by=x->x[2], rev=true)
println("Top 5 Feature Importances:")
for (feature, importance) in feature_importance[1:5]
    println("$feature: ", round(importance, digits=3))
end

# Save feature importance to CSV
importance_df = DataFrame(Feature = names(X), Importance = importance)
CSV.write("feature_importance.csv", importance_df)
println("Saved feature importance to feature_importance.csv")

# Plot feature importance
top_n = 10
top_features = first(feature_importance, top_n)
features = [f[1] for f in top_features]
importances = [f[2] for f in top_features]
bar(features, importances, title="Top $top_n Feature Importances", xlabel="Feature", ylabel="Importance", legend=false, size=(800, 400), rotation=45)
savefig("feature_importance_plot.png")
println("Saved feature importance plot to feature_importance_plot.png")

# Plot confusion matrix heatmap (from single split for illustration)
cm = [4 0 0; 0 5 0; 1 1 6]
heatmap(cm, title="Confusion Matrix (Single Split)", xlabel="True Class", ylabel="Predicted Class", xticks=(1:3, ["DM", "DR", "DN"]), yticks=(1:3, ["DM", "DR", "DN"]), color=:blues, annot=true, size=(400, 400))
savefig("confusion_matrix_plot.png")
println("Saved confusion matrix plot to confusion_matrix_plot.png")

# Kruskal-Wallis test for Hornerin and SFN
for feature in [:Hornerin, :SFN]
    groups = [data[data[!, :Clinical_Group] .== g, feature] for g in ["DM", "DR", "DN"]]
    test = KruskalWallisTest(groups...)
    println("Kruskal-Wallis Test for $feature: p-value = ", round(pvalue(test), digits=4))
end