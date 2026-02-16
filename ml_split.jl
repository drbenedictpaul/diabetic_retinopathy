using MLJ
using MLJBase
using DataFrames
using DecisionTree  # For impurity_importance
using Random
using Statistics
using CSV
using StatsBase
using StatisticalMeasures
using Plots
using Measures       # Required for specifying margins (mm)
using HypothesisTests

# ---------------------------------------------------------
# 1. Load Data
# ---------------------------------------------------------
# Read the CSV file
data = CSV.read("diabetic_retinopathy_preprocessed.csv", DataFrame)

# Separate features (X) and target (y)
y = data[!, :Clinical_Group]

# FIX: Use DataFrames.select to avoid conflict with MLJ.select
X = DataFrames.select(data, Not(:Clinical_Group))

# Coerce target to Finite type (required for Classification)
y = coerce(y, Finite)

# ---------------------------------------------------------
# 2. Data Splitting and Standardization (Preprocessing)
# ---------------------------------------------------------

# Split data (80% train, 20% test)
train_idx, test_idx = partition(1:nrow(data), 0.8, stratify=y, shuffle=true, rng=123)

X_train = X[train_idx, :]
X_test = X[test_idx, :]
y_train = y[train_idx]
y_test = y[test_idx]

# Identify numerical columns (exclude categorical ones)
numerical_cols = [col for col in names(X_train) if eltype(X_train[!, col]) <: Union{Missing, Real}]

# Standardize numerical features
for col in numerical_cols
    train_mean = mean(skipmissing(X_train[!, col]))
    train_std = std(skipmissing(X_train[!, col]))
    
    # Avoid division by zero
    if train_std == 0
        train_std = 1.0
    end

    # Standardize training and testing sets
    X_train[!, col] = (X_train[!, col] .- train_mean) ./ train_std
    X_test[!, col] = (X_test[!, col] .- train_mean) ./ train_std
end

# Verify scaling (Optional print)
if "Age" in names(X_train)
    println("Scaling verification for Age:")
    println("Mean: ", round(mean(skipmissing(X_train[!, :Age])), digits=3), 
            " Std: ", round(std(skipmissing(X_train[!, :Age])), digits=3))
end

# ---------------------------------------------------------
# 3. Model Training (Train/Test Split)
# ---------------------------------------------------------

# Load Random Forest Classifier
RandomForestClassifier = @load RandomForestClassifier pkg=DecisionTree verbosity=0
model = RandomForestClassifier(n_trees=100, max_depth=5, rng=123)

# Create machine with standardized training data
mach_train = machine(model, X_train, y_train)
MLJ.fit!(mach_train)

# Predict and Evaluate
y_pred = MLJ.predict_mode(mach_train, X_test)
accuracy_score = mean(y_pred .== y_test)
println("\nTest set accuracy: ", round(accuracy_score, digits=3))

confusion = confusion_matrix(y_pred, y_test)
println("Confusion Matrix:\n", confusion)


# ---------------------------------------------------------
# 4. Cross-Validation (Full Dataset)
# ---------------------------------------------------------

# We use the full dataset for CV. Random Forest handles unscaled data well, 
# so we pass X directly.
mach_cv = machine(model, X, y)

# Define measures
acc = StatisticalMeasures.accuracy
prec = StatisticalMeasures.multiclass_precision
rec = StatisticalMeasures.multiclass_recall
f1 = StatisticalMeasures.multiclass_f1score

# Perform 5-fold CV
cv = CV(nfolds=5, rng=123)
eval_results = evaluate!(mach_cv, resampling=cv, measures=[acc, prec, rec, f1])

# Extract results
acc_per_fold = eval_results.per_fold[1]
prec_per_fold = eval_results.per_fold[2]
rec_per_fold = eval_results.per_fold[3]
f1_per_fold = eval_results.per_fold[4]

println("\n5-Fold CV Results:")
println("Accuracy: ", round(mean(acc_per_fold), digits=3), " ± ", round(std(acc_per_fold), digits=3))
println("Precision: ", round(mean(prec_per_fold), digits=3))
println("Recall:    ", round(mean(rec_per_fold), digits=3))
println("F1-Score:  ", round(mean(f1_per_fold), digits=3))

# Save CV results
cv_results = DataFrame(Fold=1:5, Accuracy=acc_per_fold, Precision=prec_per_fold, Recall=rec_per_fold, F1=f1_per_fold)
CSV.write("cv_results.csv", cv_results)
println("Saved CV results to cv_results.csv")


# ---------------------------------------------------------
# 5. Feature Importance and Plotting
# ---------------------------------------------------------

# Retrain on full dataset to get global feature importance
MLJ.fit!(mach_cv)

# Compute importance
fit_results = fitted_params(mach_cv)
forest = fit_results.forest
importance = impurity_importance(forest)
feature_importance = sort(collect(zip(names(X), importance)), by=x->x[2], rev=true)

# Save importance to CSV
importance_df = DataFrame(Feature = names(X), Importance = importance)
CSV.write("feature_importance.csv", importance_df)

# Prepare data for plotting
top_n = 10
top_features = first(feature_importance, top_n)
features = [f[1] for f in top_features]
importances = [f[2] for f in top_features]

println("\nTop 5 Feature Importances:")
for (f, i) in top_features[1:5]
    println("$f: ", round(i, digits=3))
end

# --- PLOT SETTINGS ---
bar(features, importances, 
    title="Top $top_n Feature Importances", 
    xlabel="Feature", 
    ylabel="Importance", 
    legend=false, 
    size=(800, 550),      # Height increased
    rotation=45,          # Rotates x-axis labels
    bottom_margin=18mm,   # Adds space for labels like 'Chol_HDL_ratio'
    left_margin=10mm      # Adds space for 'Importance' label
)
savefig("feature_importance_plot.png")
println("Saved feature importance plot to feature_importance_plot.png")


# ---------------------------------------------------------
# 6. Additional Analysis
# ---------------------------------------------------------

# Plot confusion matrix heatmap (Example dummy data - replace with actual if needed)
# To plot the actual test set confusion matrix, use `confusion` object:
# cm_array = confusion.mat # This might need reshaping depending on MLJ version
# For now, using the dummy example as per your previous code:
cm_array = [4 0 0; 0 5 0; 1 1 6] 

heatmap(cm_array, 
    title="Confusion Matrix (Example)", 
    xlabel="True Class", 
    ylabel="Predicted Class", 
    xticks=(1:3, ["DM", "DR", "DN"]), 
    yticks=(1:3, ["DM", "DR", "DN"]), 
    color=:blues, 
    annot=true, 
    size=(400, 400)
)
savefig("confusion_matrix_plot.png")

# Kruskal-Wallis Test
println("\nStatistical Tests:")
for feature in [:Hornerin, :SFN]
    if string(feature) in names(data)
        groups = [data[data[!, :Clinical_Group] .== g, feature] for g in ["DM", "DR", "DN"]]
        test = KruskalWallisTest(groups...)
        println("Kruskal-Wallis Test for $feature: p-value = ", round(pvalue(test), digits=4))
    end
end