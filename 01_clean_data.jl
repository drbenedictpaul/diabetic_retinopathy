using CSV
using DataFrames
using Statistics
using CategoricalArrays

# 1. Load Raw Data
raw_data = CSV.read("diabetic_retinopathy.csv", DataFrame)

# 2. Function to clean "Nil", "-", "NaN" strings
function clean_values(x)
    if x === missing
        return missing
    elseif x isa String
        x_clean = strip(x)
        if x_clean in ["-", "Nil", "NIL", "NaN", "neg", "Neg"]
            return missing
        end
        # Try parsing as number
        try
            return parse(Float64, x_clean)
        catch
            return x_clean # Keep as string if not a number (e.g. Gender)
        end
    else
        return x
    end
end

# Apply cleaning to all columns
for col in names(raw_data)
    raw_data[!, col] = map(clean_values, raw_data[!, col])
end

# 3. RENAME GROUPS (Crucial for Reviewer #1)
# DM -> DM (Disease Control)
# DN -> Combined DR+DN
# DR -> DR (Retinopathy)
group_map = Dict(
    "DM" => "DM (Disease Control)",
    "DR" => "DR (Retinopathy)",
    "DN" => "Combined DR+DN"
)

# Apply mapping safely
raw_data.Clinical_Group = [get(group_map, g, g) for g in raw_data.Clinical_Group]

# 4. Encode Albuminuria Manually (Ordinal) to preserve order
# Map: missing -> missing, 1+ -> 1, 2+ -> 2, etc.
alb_map = Dict("1+" => 1, "2+" => 2, "3+" => 3, "4+" => 4, 0 => 0)
# Note: "Neg" was converted to missing in clean_values, we might want to treat Neg as 0
# Let's fix Neg -> 0 explicitly if it was missed or turned to missing
raw_data.Albuminuria = coalesce.(raw_data.Albuminuria, 0) # Assume missing/Neg is 0 for this specific field if appropriate, or keep missing.
# For safety in ML pipeline, let's keep it numeric. If it was "1+", clean_values might have failed to parse.
# Let's force a clean remap:
function clean_alb(x)
    s = string(x)
    if occursin("1+", s) return 1
    elseif occursin("2+", s) return 2
    elseif occursin("3+", s) return 3
    elseif occursin("4+", s) return 4
    elseif occursin("Neg", s) || occursin("neg", s) || occursin("-", s)
        return 0
    else
        return missing
    end
end
raw_data.Albuminuria = map(clean_alb, raw_data.Albuminuria)

# 5. Encode Gender
raw_data.Gender = map(x -> x == "M" ? 0 : 1, raw_data.Gender)

# 6. Save "Cleaned" but NOT "Imputed" data (Imputation happens in Pipeline)
CSV.write("diabetic_retinopathy_ready_for_pipeline.csv", raw_data)
println("Data cleaned and groups renamed. Saved to 'diabetic_retinopathy_ready_for_pipeline.csv'")