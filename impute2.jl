using DataFrames
using CSV
data = CSV.read("albuminuria_encoded.csv", DataFrame)

# # Check for missing values in each column
# for col in names(data)
#     missing_count = sum(ismissing.(data[!, col]))
#     println("Missing values in $col: $missing_count")
# end

using Statistics  # For median calculation
using DataFrames

# Replace 'Nil' with missing in all columns
for col in names(data)
    data[!, col] = replace(data[!, col], "Nil" => missing)
end

# Loop through each clinical group to impute eGFR
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing eGFR values for this group
    group_median = median(skipmissing(data[group_mask, :eGFR]))
    # Replace missing eGFR values in this group with the group median
    data[group_mask, :eGFR] = coalesce.(data[group_mask, :eGFR], group_median)
end

# Verify imputation
# println("Missing values in eGFR: ", sum(ismissing.(data[!, :eGFR])))

using Statistics  # For median calculation
using DataFrames

# Convert HB to numerical, treating 'Nil' and invalid entries as missing
data[!, :HB] = map(x -> x === missing || x == "Nil" || (x isa String && !isnumeric(x[1])) ? missing : parse(Float64, string(x)), data[!, :HB])

# Loop through each clinical group to impute HB
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing HB values for this group
    group_median = median(skipmissing(data[group_mask, :HB]))
    # Replace missing HB values in this group with the group median
    data[group_mask, :HB] = coalesce.(data[group_mask, :HB], group_median)
end

# Verify imputation
# println("Missing values in HB: ", sum(ismissing.(data[!, :HB])))

using Statistics  # For median calculation
using DataFrames

# Convert EAG to numerical, treating 'NIL', 'Nil', and invalid entries as missing
data[!, :EAG] = map(x -> x === missing || x in ["NIL", "Nil"] || (x isa String && !isnumeric(x[1])) ? missing : parse(Float64, string(x)), data[!, :EAG])

# Loop through each clinical group to impute EAG
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing EAG values for this group
    group_median = median(skipmissing(data[group_mask, :EAG]))
    # Replace missing EAG values in this group with the group median
    data[group_mask, :EAG] = coalesce.(data[group_mask, :EAG], group_median)
end

# Verify imputation
# println("Missing values in EAG: ", sum(ismissing.(data[!, :EAG])))

# using Statistics  # For median calculation
# using DataFrames

# Convert FBS to numerical, treating 'NIL', 'Nil', and invalid entries as missing
data[!, :FBS] = map(x -> x === missing || x in ["NIL", "Nil"] || (x isa String && !isnumeric(x[1])) ? missing : parse(Float64, string(x)), data[!, :FBS])

# Loop through each clinical group to impute FBS
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing FBS values for this group
    group_median = median(skipmissing(data[group_mask, :FBS]))
    # Replace missing FBS values in this group with the group median
    data[group_mask, :FBS] = coalesce.(data[group_mask, :FBS], group_median)
end

# Verify imputation
# println("Missing values in FBS: ", sum(ismissing.(data[!, :FBS])))

# using Statistics  # For median calculation
# using DataFrames

# Convert RBS to numerical, treating 'NIL', 'Nil', and invalid entries as missing
data[!, :RBS] = map(x -> x === missing || x in ["NIL", "Nil"] || (x isa String && !isnumeric(x[1])) ? missing : parse(Float64, string(x)), data[!, :RBS])

# Loop through each clinical group to impute RBS
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing RBS values for this group
    group_median = median(skipmissing(data[group_mask, :RBS]))
    # Replace missing RBS values in this group with the group median
    data[group_mask, :RBS] = coalesce.(data[group_mask, :RBS], group_median)
end

# Verify imputation
# println("Missing values in RBS: ", sum(ismissing.(data[!, :RBS])))

# using Statistics  # For median calculation
# using DataFrames

# Convert Systolic_BP to numerical, treating 'NIL', 'Nil', and invalid entries as missing
data[!, :Systolic_BP] = map(x -> x === missing || x in ["NIL", "Nil"] || (x isa String && !isnumeric(x[1])) ? missing : parse(Float64, string(x)), data[!, :Systolic_BP])

# Loop through each clinical group to impute Systolic_BP
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing Systolic_BP values for this group
    group_median = median(skipmissing(data[group_mask, :Systolic_BP]))
    # Replace missing Systolic_BP values in this group with the group median
    data[group_mask, :Systolic_BP] = coalesce.(data[group_mask, :Systolic_BP], group_median)
end

# Verify imputation
# println("Missing values in Systolic_BP: ", sum(ismissing.(data[!, :Systolic_BP])))

# using Statistics  # For median calculation
# using DataFrames

# Convert Diastolic_BP to numerical, treating 'NIL', 'Nil', and invalid entries as missing
data[!, :Diastolic_BP] = map(x -> x === missing || x in ["NIL", "Nil"] || (x isa String && !isnumeric(x[1])) ? missing : parse(Float64, string(x)), data[!, :Diastolic_BP])

# Loop through each clinical group to impute Diastolic_BP
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing Diastolic_BP values for this group
    group_median = median(skipmissing(data[group_mask, :Diastolic_BP]))
    # Replace missing Diastolic_BP values in this group with the group median
    data[group_mask, :Diastolic_BP] = coalesce.(data[group_mask, :Diastolic_BP], group_median)
end

# Verify imputation
# println("Missing values in Diastolic_BP: ", sum(ismissing.(data[!, :Diastolic_BP])))

# using Statistics  # For median calculation
# using DataFrames

# Convert BUN to numerical, treating 'NIL', 'Nil', and invalid entries as missing
data[!, :BUN] = map(x -> x === missing || x in ["NIL", "Nil"] || (x isa String && !isnumeric(x[1])) ? missing : parse(Float64, string(x)), data[!, :BUN])

# Loop through each clinical group to impute BUN
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing BUN values for this group
    group_median = median(skipmissing(data[group_mask, :BUN]))
    # Replace missing BUN values in this group with the group median
    data[group_mask, :BUN] = coalesce.(data[group_mask, :BUN], group_median)
end

# Verify imputation
# println("Missing values in BUN: ", sum(ismissing.(data[!, :BUN])))

# using Statistics  # For median calculation
# using DataFrames

# Convert Total_Protein to numerical, treating 'NIL', 'Nil', and invalid entries as missing
data[!, :Total_Protein] = map(x -> x === missing || x in ["NIL", "Nil"] || (x isa String && !isnumeric(x[1])) ? missing : parse(Float64, string(x)), data[!, :Total_Protein])

# Loop through each clinical group to impute Total_Protein
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing Total_Protein values for this group
    group_median = median(skipmissing(data[group_mask, :Total_Protein]))
    # Replace missing Total_Protein values in this group with the group median
    data[group_mask, :Total_Protein] = coalesce.(data[group_mask, :Total_Protein], group_median)
end

# Verify imputation
# println("Missing values in Total_Protein: ", sum(ismissing.(data[!, :Total_Protein])))

# using Statistics  # For median calculation
# using DataFrames

# Convert Serum_Albumin to numerical, treating 'NIL', 'Nil', and invalid entries as missing
data[!, :Serum_Albumin] = map(x -> x === missing || x in ["NIL", "Nil"] || (x isa String && !isnumeric(x[1])) ? missing : parse(Float64, string(x)), data[!, :Serum_Albumin])

# Loop through each clinical group to impute Serum_Albumin
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing Serum_Albumin values for this group
    group_median = median(skipmissing(data[group_mask, :Serum_Albumin]))
    # Replace missing Serum_Albumin values in this group with the group median
    data[group_mask, :Serum_Albumin] = coalesce.(data[group_mask, :Serum_Albumin], group_median)
end

# Verify imputation
# println("Missing values in Serum_Albumin: ", sum(ismissing.(data[!, :Serum_Albumin])))

# using Statistics  # For median calculation
# using DataFrames

# Convert Serum_Globulin to numerical, treating 'NIL', 'Nil', and invalid entries as missing
data[!, :Serum_Globulin] = map(x -> x === missing || x in ["NIL", "Nil"] || (x isa String && !isnumeric(x[1])) ? missing : parse(Float64, string(x)), data[!, :Serum_Globulin])

# Loop through each clinical group to impute Serum_Globulin
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing Serum_Globulin values for this group
    group_median = median(skipmissing(data[group_mask, :Serum_Globulin]))
    # Replace missing Serum_Globulin values in this group with the group median
    data[group_mask, :Serum_Globulin] = coalesce.(data[group_mask, :Serum_Globulin], group_median)
end

# Verify imputation
# println("Missing values in Serum_Globulin: ", sum(ismissing.(data[!, :Serum_Globulin])))

# using Statistics  # For median calculation
# using DataFrames

# Convert AG_Ratio to numerical, treating 'NIL', 'Nil', and invalid entries as missing
data[!, :AG_Ratio] = map(x -> x === missing || x in ["NIL", "Nil"] || (x isa String && !isnumeric(x[1])) ? missing : parse(Float64, string(x)), data[!, :AG_Ratio])

# Loop through each clinical group to impute AG_Ratio
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing AG_Ratio values for this group
    group_median = median(skipmissing(data[group_mask, :AG_Ratio]))
    # Replace missing AG_Ratio values in this group with the group median
    data[group_mask, :AG_Ratio] = coalesce.(data[group_mask, :AG_Ratio], group_median)
end

# Verify imputation
# println("Missing values in AG_Ratio: ", sum(ismissing.(data[!, :AG_Ratio])))

CSV.write("imputed_ag_ratio.csv", data)