using DataFrames
using CSV
using Statistics

data = CSV.read("imputed_ag_ratio.csv", DataFrame)

# using Statistics  # For median calculation
# using DataFrames

# Convert Sodium to numerical, treating 'NIL', 'Nil', and invalid entries as missing
data[!, :Sodium] = map(x -> x === missing || x in ["NIL", "Nil"] || (x isa String && !isnumeric(x[1])) ? missing : parse(Float64, string(x)), data[!, :Sodium])

# Loop through each clinical group to impute Sodium
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing Sodium values for this group
    group_median = median(skipmissing(data[group_mask, :Sodium]))
    # Replace missing Sodium values in this group with the group median
    data[group_mask, :Sodium] = coalesce.(data[group_mask, :Sodium], group_median)
end

# # Verify imputation
# println("Missing values in Sodium: ", sum(ismissing.(data[!, :Sodium])))

# using Statistics  # For median calculation
# using DataFrames

# Convert Potassium to numerical, treating 'NIL', 'Nil', and invalid entries as missing
data[!, :Potassium] = map(x -> x === missing || x in ["NIL", "Nil"] || (x isa String && !isnumeric(x[1])) ? missing : parse(Float64, string(x)), data[!, :Potassium])

# Loop through each clinical group to impute Potassium
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing Potassium values for this group
    group_median = median(skipmissing(data[group_mask, :Potassium]))
    # Replace missing Potassium values in this group with the group median
    data[group_mask, :Potassium] = coalesce.(data[group_mask, :Potassium], group_median)
end

# Verify imputation
# println("Missing values in Potassium: ", sum(ismissing.(data[!, :Potassium])))

# using Statistics  # For median calculation
# using DataFrames

# Convert Chloride to numerical, treating 'NIL', 'Nil', and invalid entries as missing
data[!, :Chloride] = map(x -> x === missing || x in ["NIL", "Nil"] || (x isa String && !isnumeric(x[1])) ? missing : parse(Float64, string(x)), data[!, :Chloride])

# Loop through each clinical group to impute Chloride
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing Chloride values for this group
    group_median = median(skipmissing(data[group_mask, :Chloride]))
    # Replace missing Chloride values in this group with the group median
    data[group_mask, :Chloride] = coalesce.(data[group_mask, :Chloride], group_median)
end

# Verify imputation
# println("Missing values in Chloride: ", sum(ismissing.(data[!, :Chloride])))

# using Statistics  # For median calculation
# using DataFrames

# Convert Bicarbonate to numerical, treating 'NIL', 'Nil', and invalid entries as missing
data[!, :Bicarbonate] = map(x -> x === missing || x in ["NIL", "Nil"] || (x isa String && !isnumeric(x[1])) ? missing : parse(Float64, string(x)), data[!, :Bicarbonate])

# Loop through each clinical group to impute Bicarbonate
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing Bicarbonate values for this group
    group_median = median(skipmissing(data[group_mask, :Bicarbonate]))
    # Replace missing Bicarbonate values in this group with the group median
    data[group_mask, :Bicarbonate] = coalesce.(data[group_mask, :Bicarbonate], group_median)
end

# Verify imputation
# println("Missing values in Bicarbonate: ", sum(ismissing.(data[!, :Bicarbonate])))

# using Statistics  # For median calculation
# using DataFrames

# Convert SGOT to numerical, treating 'NIL', 'Nil', and invalid entries as missing
data[!, :SGOT] = map(x -> x === missing || x in ["NIL", "Nil"] || (x isa String && !isnumeric(x[1])) ? missing : parse(Float64, string(x)), data[!, :SGOT])

# Loop through each clinical group to impute SGOT
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing SGOT values for this group
    group_median = median(skipmissing(data[group_mask, :SGOT]))
    # Replace missing NIR values in this group with the group median
    data[group_mask, :SGOT] = coalesce.(data[group_mask, :SGOT], group_median)
end

# Verify imputation
# println("Missing values in SGOT: ", sum(ismissing.(data[!, :SGOT])))

# using Statistics  # For median calculation
# using DataFrames

# Convert SGPT to numerical, treating 'NIL', 'Nil', and invalid entries as missing
data[!, :SGPT] = map(x -> x === missing || x in ["NIL", "Nil"] || (x isa String && !isnumeric(x[1])) ? missing : parse(Float64, string(x)), data[!, :SGPT])

# Loop through each clinical group to impute SGPT
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing SGPT values for this group
    group_median = median(skipmissing(data[group_mask, :SGPT]))
    # Replace missing SGPT values in this group with the group median
    data[group_mask, :SGPT] = coalesce.(data[group_mask, :SGPT], group_median)
end

# Verify imputation
# println("Missing values in SGPT: ", sum(ismissing.(data[!, :SGPT])))

# using Statistics  # For median calculation
# using DataFrames

# Convert Alkaline_Phosphatase to numerical, treating 'NIL', 'Nil', and invalid entries as missing
data[!, :Alkaline_Phosphatase] = map(x -> x === missing || x in ["NIL", "Nil"] || (x isa String && !isnumeric(x[1])) ? missing : parse(Float64, string(x)), data[!, :Alkaline_Phosphatase])

# Loop through each clinical group to impute Alkaline_Phosphatase
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing Alkaline_Phosphatase values for this group
    group_median = median(skipmissing(data[group_mask, :Alkaline_Phosphatase]))
    # Replace missing Alkaline_Phosphatase values in this group with the group median
    data[group_mask, :Alkaline_Phosphatase] = coalesce.(data[group_mask, :Alkaline_Phosphatase], group_median)
end

# Verify imputation
# println("Missing values in Alkaline_Phosphatase: ", sum(ismissing.(data[!, :Alkaline_Phosphatase])))

# using Statistics  # For median calculation
# using DataFrames

# Convert T_Bil to numerical, treating 'NIL', 'Nil', and invalid entries as missing
data[!, :T_Bil] = map(x -> x === missing || x in ["NIL", "Nil"] || (x isa String && !isnumeric(x[1])) ? missing : parse(Float64, string(x)), data[!, :T_Bil])

# Loop through each clinical group to impute T_Bil
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing T_Bil values for this group
    group_median = median(skipmissing(data[group_mask, :T_Bil]))
    # Replace missing T_Bil values in this group with the group median
    data[group_mask, :T_Bil] = coalesce.(data[group_mask, :T_Bil], group_median)
end

# Verify imputation
# println("Missing values in T_Bil: ", sum(ismissing.(data[!, :T_Bil])))

# using Statistics  # For median calculation
# using DataFrames

# Convert D_Bil to numerical, treating 'NIL', 'Nil', invalid numerical formats, and non-numerical entries as missing
data[!, :D_Bil] = map(x -> begin
    if x === missing || x in ["NIL", "Nil"] || (x isa String && !occursin(r"^[0-9]+(\.[0-9]+)?$", string(x)))
        return missing
    else
        return parse(Float64, string(x))
    end
end, data[!, :D_Bil])

# Loop through each clinical group to impute D_Bil
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing D_Bil values for this group
    group_median = median(skipmissing(data[group_mask, :D_Bil]))
    # Replace missing D_Bil values in this group with the group median
    data[group_mask, :D_Bil] = coalesce.(data[group_mask, :D_Bil], group_median)
end

# Verify imputation
# println("Missing values in D_Bil: ", sum(ismissing.(data[!, :D_Bil])))

# using Statistics  # For median calculation
# using DataFrames

# Convert HDL to numerical, treating 'NIL', 'Nil', invalid numerical formats, and non-numerical entries as missing
data[!, :HDL] = map(x -> begin
    if x === missing || x in ["NIL", "Nil"] || (x isa String && !occursin(r"^[0-9]+(\.[0-9]+)?$", string(x)))
        return missing
    else
        return parse(Float64, string(x))
    end
end, data[!, :HDL])

# Loop through each clinical group to impute HDL
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing HDL values for this group
    group_median = median(skipmissing(data[group_mask, :HDL]))
    # Replace missing HDL values in this group with the group median
    data[group_mask, :HDL] = coalesce.(data[group_mask, :HDL], group_median)
end

# Verify imputation
# println("Missing values in HDL: ", sum(ismissing.(data[!, :HDL])))

# using Statistics  # For median calculation
# using DataFrames

# Convert LDL to numerical, treating 'NIL', 'Nil', invalid numerical formats, and non-numerical entries as missing
data[!, :LDL] = map(x -> begin
    if x === missing || x in ["NIL", "Nil"] || (x isa String && !occursin(r"^[0-9]+(\.[0-9]+)?$", string(x)))
        return missing
    else
        return parse(Float64, string(x))
    end
end, data[!, :LDL])

# Loop through each clinical group to impute LDL
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing LDL values for this group
    group_median = median(skipmissing(data[group_mask, :LDL]))
    # Replace missing LDL values in this group with the group median
    data[group_mask, :LDL] = coalesce.(data[group_mask, :LDL], group_median)
end

# Verify imputation
# println("Missing values in LDL: ", sum(ismissing.(data[!, :LDL])))

# using Statistics  # For median calculation
# using DataFrames

# Convert CHOL to numerical, treating 'NIL', 'Nil', invalid numerical formats, and non-numerical entries as missing
data[!, :CHOL] = map(x -> begin
    if x === missing || x in ["NIL", "Nil"] || (x isa String && !occursin(r"^[0-9]+(\.[0-9]+)?$", string(x)))
        return missing
    else
        return parse(Float64, string(x))
    end
end, data[!, :CHOL])

# Loop through each clinical group to impute CHOL
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing CHOL values for this group
    group_median = median(skipmissing(data[group_mask, :CHOL]))
    # Replace missing CHOL values in this group with the group median
    data[group_mask, :CHOL] = coalesce.(data[group_mask, :CHOL], group_median)
end

# Verify imputation
# println("Missing values in CHOL: ", sum(ismissing.(data[!, :CHOL])))

using Statistics  # For median calculation
using DataFrames

# Convert Chol_HDL_ratio to numerical, treating 'NIL', 'Nil', invalid numerical formats, and non-numerical entries as missing
data[!, :Chol_HDL_ratio] = map(x -> begin
    if x === missing || x in ["NIL", "Nil"] || (x isa String && !occursin(r"^[0-9]+(\.[0-9]+)?$", string(x)))
        return missing
    else
        return parse(Float64, string(x))
    end
end, data[!, :Chol_HDL_ratio])

# Loop through each clinical group to impute Chol_HDL_ratio
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing Chol_HDL_ratio values for this group
    group_median = median(skipmissing(data[group_mask, :Chol_HDL_ratio]))
    # Replace missing Chol_HDL_ratio values in this group with the group median
    data[group_mask, :Chol_HDL_ratio] = coalesce.(data[group_mask, :Chol_HDL_ratio], group_median)
end

# Verify imputation
# println("Missing values in Chol_HDL_ratio: ", sum(ismissing.(data[!, :Chol_HDL_ratio])))

using Statistics  # For median calculation
using DataFrames

# Convert TG to numerical, treating 'NIL', 'Nil', invalid numerical formats, and non-numerical entries as missing
data[!, :TG] = map(x -> begin
    if x === missing || x in ["NIL", "Nil"] || (x isa String && !occursin(r"^[0-9]+(\.[0-9]+)?$", string(x)))
        return missing
    else
        return parse(Float64, string(x))
    end
end, data[!, :TG])

# Loop through each clinical group to impute TG
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing TG values for this group
    group_median = median(skipmissing(data[group_mask, :TG]))
    # Replace missing TG values in this group with the group median
    data[group_mask, :TG] = coalesce.(data[group_mask, :TG], group_median)
end

# Verify imputation
# println("Missing values in TG: ", sum(ismissing.(data[!, :TG])))

# CSV.write("imputed_tg.csv", data)

# Check for missing values in each column
for col in names(data)
    missing_count = sum(ismissing.(data[!, col]))
    println("Missing values in $col: $missing_count")
end


