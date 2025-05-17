using CSV
using DataFrames
using Impute
using StatsBase
using Random
using PrettyTables

# Load the dataset
data = CSV.read("Hornerin_SFN_imputed.csv", DataFrame)

using Statistics  # Required for median calculation

# Loop through each clinical group
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing Age values for this group
    group_median = median(skipmissing(data[group_mask, :Age]))
    # Replace missing Age values in this group with the group median
    data[group_mask, :Age] = coalesce.(data[group_mask, :Age], group_median)
end
println(data)

# CSV.write("diabetic_retinopathy_imputed.csv", data)

using Statistics  # Required for median calculation

# Loop through each clinical group
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing Diabetic_Duration values for this group
    group_median = median(skipmissing(data[group_mask, :Diabetic_Duration]))
    # Replace missing Diabetic_Duration values in this group with the group median
    data[group_mask, :Diabetic_Duration] = coalesce.(data[group_mask, :Diabetic_Duration], group_median)
end
# println("Missing values in Diabetic_Duration: ", sum(ismissing.(data[!, :Diabetic_Duration])))

# CSV.write("diabetic_retinopathy_imputed_Diabetic_Duration.csv", data)

using Statistics  # Required for median calculation

# Loop through each clinical group
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing HbA1C values for this group
    group_median = median(skipmissing(data[group_mask, :HbA1C]))
    # Replace missing HbA1C values in this group with the group median
    data[group_mask, :HbA1C] = coalesce.(data[group_mask, :HbA1C], group_median)
end
using Statistics  # For mode calculation

# Function to calculate mode (most frequent value) for a vector
function mode(x)
    # Skip missing values and return most frequent non-missing value
    counts = countmap(skipmissing(x))
    return findmax(counts)[2]  # Return key with highest count
end

# Loop through each clinical group
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate mode of non-missing Albuminuria values for this group
    group_mode = mode(data[group_mask, :Albuminuria])
    # Replace missing Albuminuria values in this group with the group mode
    data[group_mask, :Albuminuria] = coalesce.(data[group_mask, :Albuminuria], group_mode)
end
println("Missing values in Albuminuria: ", sum(ismissing.(data[!, :Albuminuria])))

using Pkg
Pkg.add("StatsBase")
using StatsBase  # For countmap

# CSV.write("diabetic_retinopathy_imputed Albuminuria.csv", data)

