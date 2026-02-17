using MLJ
using MLJBase
using DataFrames
using CSV
using Statistics
using Random
using DecisionTree

# ---------------------------------------------------------
# 1. LOAD AND CLEAN DATA
# ---------------------------------------------------------
println("Loading data...")
data = CSV.read("diabetic_retinopathy_ready_for_pipeline.csv", DataFrame, 
                missingstring=["", "missing", "NaN", "nan", "NA", "Nil", "-"])

# Coerce Target
y = coerce(data.Clinical_Group, Multiclass)

# Select Features
X_all = DataFrames.select(data, Not([:Clinical_Group, :Patient_ID]))

# --- ROBUST NUMERIC CLEANING ---
function clean_numeric_data!(df)
    for col in names(df)
        df[!, col] = map(x -> begin
            if x === missing return missing
            elseif x isa Number return isnan(x) ? missing : Float64(x)
            elseif x isa AbstractString
                s = strip(string(x))
                if isempty(s) || lowercase(s) in ["nil", "nan", "-", "missing"] return missing end
                try return parse(Float64, s) catch; return missing end
            else return missing end
        end, df[!, col])
        df[!, col] = Vector{Union{Missing, Float64}}(df[!, col])
    end
end

println("Cleaning numeric data...")
clean_numeric_data!(X_all)

# --- REMOVE BAD COLUMNS ---
function drop_bad_cols(df)
    cols_to_keep = Symbol[]
    for col in names(df)
        if all(ismissing, df[!, col])
            println("Dropping empty column: $col")
            continue
        end
        try
            std_val = std(skipmissing(df[!, col]))
            if !isnan(std_val) && std_val > 1e-6
                push!(cols_to_keep, Symbol(col))
            else
                println("Dropping constant column: $col")
            end
        catch
            println("Dropping problematic column: $col")
        end
    end
    return DataFrames.select(df, cols_to_keep)
end

println("Checking for constant columns...")
X_final = drop_bad_cols(X_all)
coerce!(X_final, Count => Continuous)

println("Features remaining: ", ncol(X_final))

# ---------------------------------------------------------
# 2. SETUP MODELS (GLOBAL SCOPE)
# ---------------------------------------------------------
RF_Class = @load RandomForestClassifier pkg=DecisionTree verbosity=0

# ---------------------------------------------------------
# 3. DEFINE MANUAL CV FUNCTION
# ---------------------------------------------------------

function run_manual_cv(X, y, ModelType; nfolds=5, rng=123)
    cv = StratifiedCV(nfolds=nfolds, shuffle=true, rng=rng)
    folds = MLJBase.train_test_pairs(cv, 1:nrows(X), y)
    accuracies = Float64[]
    
    for (i, (train_idx, test_idx)) in enumerate(folds)
        X_train_raw = X[train_idx, :]
        y_train = y[train_idx]
        X_test_raw = X[test_idx, :]
        y_test = y[test_idx]
        
        # 1. IMPUTE (Train only)
        imp_model = FillImputer(continuous_fill = x -> median(skipmissing(x)), count_fill = x -> mode(skipmissing(x)))
        imp_mach = machine(imp_model, X_train_raw)
        MLJ.fit!(imp_mach, verbosity=0)
        
        X_train = MLJ.transform(imp_mach, X_train_raw)
        X_test = MLJ.transform(imp_mach, X_test_raw)
        
        # 2. TRAIN RF
        rf_model = ModelType(n_trees=100, max_depth=5, rng=123)
        rf_mach = machine(rf_model, X_train, y_train)
        MLJ.fit!(rf_mach, verbosity=0)
        
        # 3. PREDICT
        y_pred = MLJ.predict_mode(rf_mach, X_test)
        acc = mean(y_pred .== y_test)
        push!(accuracies, acc)
    end
    
    return mean(accuracies), std(accuracies)
end

# ---------------------------------------------------------
# 4. ABLATION ANALYSIS
# ---------------------------------------------------------
println("\n--- STARTING ABLATION ANALYSIS (MANUAL CV) ---")

available_biomarkers = intersect([:Hornerin, :SFN], Symbol.(names(X_final)))
if !isempty(available_biomarkers)
    X_clinical = DataFrames.select(X_final, Not(available_biomarkers))
else
    X_clinical = X_final
end

println("\n1. Training Baseline Model (Clinical Only)...")
acc_A, std_A = run_manual_cv(X_clinical, y, RF_Class)
println("Baseline Accuracy: ", round(acc_A, digits=3), " ± ", round(std_A, digits=3))

println("\n2. Training Full Model (Clinical + Candidates)...")
acc_B, std_B = run_manual_cv(X_final, y, RF_Class)
println("Full Model Accuracy: ", round(acc_B, digits=3), " ± ", round(std_B, digits=3))

delta = acc_B - acc_A
println("\n>>> Net Performance Gain: ", round(delta, digits=3))

# ---------------------------------------------------------
# 5. FEATURE IMPORTANCE
# ---------------------------------------------------------
println("\n--- EXTRACTING FEATURE IMPORTANCE ---")

# 1. Impute Whole Dataset
imp_model = FillImputer(continuous_fill = x -> median(skipmissing(x)), count_fill = x -> mode(skipmissing(x)))
imp_mach = machine(imp_model, X_final)
MLJ.fit!(imp_mach, verbosity=0)
X_imputed = MLJ.transform(imp_mach, X_final)

# 2. Fit RF
rf_mach = machine(RF_Class(n_trees=100, max_depth=5, rng=123), X_imputed, y)
MLJ.fit!(rf_mach, verbosity=0)

# 3. Get Importance (FIXED LINE BELOW)
fp = fitted_params(rf_mach)
# The field is named :forest, not :fit_result
forest_obj = fp.forest

feat_imp = impurity_importance(forest_obj)

# 4. Save
imp_df = DataFrame(Feature=names(X_final), Importance=feat_imp)
sort!(imp_df, :Importance, rev=true)

println("Top 10 Predictors:")
println(first(imp_df, 10))

CSV.write("final_feature_importance.csv", imp_df)
CSV.write("final_cv_results_model_B.csv", DataFrame(Accuracy_Mean=acc_B, Accuracy_Std=std_B))

println("\nAnalysis Complete. Files saved.")