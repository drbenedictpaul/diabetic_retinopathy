using CSV
using DataFrames
using Impute
using StatsBase
using Random
using PrettyTables

# Load the dataset
data = CSV.read("diabetic_retinopathy.csv", DataFrame)

# # Display basic information
# println("Dataset Info:")
# println(describe(data))
# println("First few rows:")
# println(first(data, 5))

# # Check class distribution
# println("Class Distribution:")
# println(combine(groupby(data, :Clinical_Group), nrow => :count))

# Replace "NIL" and "Nil" with missing
for col in names(data)
    data[!, col] = replace(data[!, col], "NIL" => missing, "Nil" => missing, "NaN" => missing)
end

# Separate numerical and categorical columns
numerical_cols = [:Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, 
                  :Systolic_BP, :Diastolic_BP, :BUN, :Total_Protein, :Serum_Albumin, :Serum_Globulin, 
                  :AG_Ratio, :Serum_Creatinine, :Sodium, :Potassium, :Chloride, :Bicarbonate, :SGOT, 
                  :SGPT, :Alkaline_Phosphatase, :T_Bil, :D_Bil, :HDL, :LDL, :CHOL, :Chol_HDL_ratio, :TG]
categorical_cols = [:Gender, :Albuminuria]

# Impute numerical columns with srs
for col in numerical_cols
    if eltype(data[!, col]) <: Union{Missing, Number}
        rng = MersenneTwister(42)
        data[!, col] = Impute.srs(data[!, col], rng=rng)
    end
end

# Impute categorical columns with mode
for col in categorical_cols
    if eltype(data[!, col]) <: Union{Missing, String}
        mode_val = mode(skipmissing(data[!, col]))
        data[!, col] = coalesce.(data[!, col], mode_val)
    end
end

using MLJ, MLJBase, DataFrames

# Encode categorical variables
data[!, :Clinical_Group] = categorical(data[!, :Clinical_Group])
hot_encoder = OneHotEncoder(; features=[:Gender, :Albuminuria], drop_last=false)
mach = machine(hot_encoder, data)
fit!(mach)
data_encoded = MLJBase.transform(mach, data)
data_encoded = DataFrames.select(data_encoded, Not([:Gender, :Albuminuria]))
pretty_table(data_encoded)