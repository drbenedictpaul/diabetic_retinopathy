using CSV
using DataFrames
using Impute
using StatsBase
using Random
using PrettyTables

# Load the dataset
data = CSV.read("diabetic_retinopathy.csv", DataFrame)
DataFrames.describe(data)

# # Display basic information
# println("Dataset Info:")
# println(describe(data))
# println("First few rows:")
# println(first(data, 5))

# # Check class distribution
# println("Class Distribution:")
# println(combine(groupby(data, :Clinical_Group), nrow => :count))

for col in names(data)
    # Replace string "NaN"
    data[!, col] = replace(data[!, col], "NaN" => missing)
    # Replace floating-point NaN for numerical columns
    if eltype(data[!, col]) <: Union{Missing, Number}
        data[!, col] = map(x -> isequal(x, NaN) ? missing : x, data[!, col])
    end
end

# println(data)
# missing_data = data 
# pretty_table(data)

CSV.write("diabetic_retinopathy_missing_removed.csv", data)

using Statistics  # Required for median calculation

# Loop through each clinical group
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing Hornerin values for this group
    group_median = median(skipmissing(data[group_mask, :Hornerin]))
    # Replace missing Hornerin values in this group with the group median
    data[group_mask, :Hornerin] = coalesce.(data[group_mask, :Hornerin], group_median)
end

# println(data[!, :Hornerin])

using Statistics  # Required for median calculation

# Loop through each clinical group
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing SFN values for this group
    group_median = median(skipmissing(data[group_mask, :SFN]))
    # Replace missing SFN values in this group with the group median
    data[group_mask, :SFN] = coalesce.(data[group_mask, :SFN], group_median)
end

# println(data[!, :SFN])
# CSV.write("Hornerin_SFN_imputed.csv",data)
println("Missing values in SFN: ", sum(ismissing.(data[!, :SFN])))