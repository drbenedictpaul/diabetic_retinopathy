using CSV  # For reading CSV files
using DataFrames  # For DataFrame operations
using Statistics  # For median and mode calculations
using StatsBase  # For countmap in mode function
using MLJ  # For categorical type
using PrettyTables  # For pretty printing

# Load the dataset
data = CSV.read("Hornerin_SFN_imputed.csv", DataFrame)

# Impute numerical columns (Age, Diabetic_Duration, HbA1C) with group median
for col in [:Age, :Diabetic_Duration, :HbA1C]
    for group in unique(data[!, :Clinical_Group])
        # Filter rows for the current group
        group_mask = data[!, :Clinical_Group] .== group
        # Calculate median of non-missing values for this column and group
        group_median = median(skipmissing(data[group_mask, col]))
        # Replace missing values in this group with the group median
        data[group_mask, col] = coalesce.(data[group_mask, col], group_median)
    end
    # Verify imputation
    println("Missing values in $col: ", sum(ismissing.(data[!, col])))
end

# Clean Albuminuria: trim whitespace and replace '-' with missing
data[!, :Albuminuria] = strip.(string.(data[!, :Albuminuria]))
data[!, :Albuminuria] = replace(data[!, :Albuminuria], "-" => missing)

# Function to calculate mode (most frequent value) for a vector
function mode(x)
    counts = countmap(skipmissing(x))
    return findmax(counts)[2]  # Return key with highest count
end

# Impute Albuminuria with group mode
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate mode of non-missing Albuminuria values for this group
    group_mode = mode(data[group_mask, :Albuminuria])
    # Replace missing Albuminuria values in this group with the group mode
    data[group_mask, :Albuminuria] = coalesce.(data[group_mask, :Albuminuria], group_mode)
end
# Verify imputation
# println("Missing values in Albuminuria: ", sum(ismissing.(data[!, :Albuminuria])))
# println("Unique values in Albuminuria: ", unique(data[!, :Albuminuria]))

# Convert Clinical_Group to categorical (target variable)
data[!, :Clinical_Group] = categorical(data[!, :Clinical_Group], ordered=false)

# Define the mapping for Albuminuria
albuminuria_map = Dict("Neg" => 0, "neg" => 0, "1+" => 1, "2+" => 2, "3+" => 3, "4+" => 4)

# Apply label encoding to Albuminuria
data[!, :Albuminuria] = [ismissing(x) ? missing : albuminuria_map[x] for x in data[!, :Albuminuria]]

# Ensure Albuminuria is of integer type
data[!, :Albuminuria] = convert(Vector{Int}, data[!, :Albuminuria])

# Verify encoding
# println("Albuminuria unique values: ", unique(data[!, :Albuminuria]))
# println("Albuminuria mapping: ", albuminuria_map)

# Display Albuminuria column
# pretty_table(data[!, :Albuminuria])
CSV.write("albuminuria_encoded.csv", data)