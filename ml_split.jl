using MLJ  # For data splitting
using DataFrames
using StatsBase  # For class distribution
using CSV

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
println("Training set rows: ", nrow(X_train))
println("Testing set rows: ", nrow(X_test))
println("Training class distribution: ", countmap(y_train))
println("Testing class distribution: ", countmap(y_test))

