using Impute
using StatsBase

# Replace "NIL" and "Nil" with missing
for col in names(data)
    data[!, col] = replace(data[!, col], "NIL" => missing, "Nil" => missing)
end

# Separate numerical and categorical columns
numerical_cols = [:Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, 
                  :Systolic_BP, :Diastolic_BP, :BUN, :Total_Protein, :Serum_Albumin, :Serum_Globulin, 
                  :AG_Ratio, :Serum_Creatinine, :Sodium, :Potassium, :Chloride, :Bicarbonate, :SGOT, 
                  :SGPT, :Alkaline_Phosphatase, :T_Bil, :D_Bil, :HDL, :LDL, :CHOL, :Chol_HDL_ratio, :TG]
categorical_cols = [:Gender, :Albuminuria]

# Impute numerical columns with median
for col in numerical_cols
    if eltype(data[!, col]) <: Union{Missing, Number}
        data[!, col] = Impute.srs(data[!, col]; rng=42)  # Simple random sampling for missing values
    end
end

# Impute categorical columns with mode
for col in categorical_cols
    if eltype(data[!, col]) <: Union{Missing, String}
        mode_val = mode(skipmissing(data[!, col]))
        data[!, col] = coalesce.(data[!, col], mode_val)
    end
end