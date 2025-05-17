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