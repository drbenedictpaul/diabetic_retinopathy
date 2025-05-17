using DataFrames
using CSV
using PrettyTables
using MLJ  # For categorical type

data = CSV.read("imputed_tg.csv", DataFrame)

# Verify no missing values in any column
for col in names(data)
    missing_count = sum(ismissing.(data[!, col]))
    println("Missing values in $col: $missing_count")
end

# Encode Gender (M -> 0, F -> 1)
gender_map = Dict("M" => 0, "F" => 1)
data[!, :Gender] = [gender_map[x] for x in data[!, :Gender]]

# Ensure Gender is of integer type
data[!, :Gender] = convert(Vector{Int}, data[!, :Gender])

# Verify encoding
# println("Gender unique values: ", unique(data[!, :Gender]))
# println("Gender mapping: ", gender_map)
# println(first(data, 5))  # View first 5 rows

# pretty_table(data.HB)

# using DataFrames
# using CSV

# Drop Patient_ID column
select!(data, Not(:Patient_ID))

# Verify the updated DataFrame structure
println("Remaining columns: ", names(data))
println(first(data, 5))  # View first 5 rows

# Save the preprocessed dataset
CSV.write("diabetic_retinopathy_preprocessed.csv", data)