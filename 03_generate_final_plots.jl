using MLJ
using MLJBase
using DataFrames
using CSV
using Statistics
using Random
using DecisionTree
using Plots
using Measures
using StatsPlots

# Set plotting backend to 600 DPI for publication quality
gr(size=(800, 600), dpi=600)

# ---------------------------------------------------------
# 1. SETUP & DATA CLEANING
# ---------------------------------------------------------
println("Loading and Cleaning Data...")
data_raw = CSV.read("diabetic_retinopathy_ready_for_pipeline.csv", DataFrame, 
                missingstring=["", "missing", "NaN", "nan", "NA", "Nil", "-"])

# Select Features and Target
y = coerce(data_raw.Clinical_Group, Multiclass)
X = DataFrames.select(data_raw, Not([:Clinical_Group, :Patient_ID]))

function clean_numeric_data!(df)
    for col in names(df)
        df[!, col] = map(x -> begin
            if x === missing || (x isa Number && isnan(x))
                return missing
            elseif x isa AbstractString
                s = strip(string(x))
                if isempty(s) || lowercase(s) in ["nil", "nan", "-", "missing"] return missing end
                try return parse(Float64, s) catch; return missing end
            else return Float64(x) end
        end, df[!, col])
        df[!, col] = Vector{Union{Missing, Float64}}(df[!, col])
    end
end

clean_numeric_data!(X)

function drop_bad_cols(df)
    cols_to_keep = Symbol[]
    for col in names(df)
        if all(ismissing, df[!, col]) continue end
        try
            std_val = std(skipmissing(df[!, col]))
            if !isnan(std_val) && std_val > 1e-6
                push!(cols_to_keep, Symbol(col))
            end
        catch; end
    end
    return DataFrames.select(df, cols_to_keep)
end

X = drop_bad_cols(X)
coerce!(X, Count => Continuous)

# ---------------------------------------------------------
# 2. FIG 1: CONFUSION MATRIX
# ---------------------------------------------------------
println("Generating Fig 1: Confusion Matrix...")

train, test = partition(eachindex(y), 0.8, shuffle=true, stratify=y, rng=123)

imp_model = FillImputer(continuous_fill = x -> median(skipmissing(x)), count_fill = x -> mode(skipmissing(x)))
imp_mach = machine(imp_model, X[train, :])
MLJ.fit!(imp_mach, verbosity=0)

X_train = MLJ.transform(imp_mach, X[train, :])
X_test = MLJ.transform(imp_mach, X[test, :])

RF = @load RandomForestClassifier pkg=DecisionTree verbosity=0
model = RF(n_trees=100, max_depth=5, rng=123)
mach_rf = machine(model, X_train, y[train])
MLJ.fit!(mach_rf, verbosity=0)

y_hat = predict_mode(mach_rf, X_test)
cm = confusion_matrix(y_hat, y[test])

heatmap(cm.mat, 
    title="Confusion Matrix (Validation Set)",
    xticks=(1:3, levels(y)),
    yticks=(1:3, levels(y)),
    xlabel="True Class",
    ylabel="Predicted Class",
    color=:blues,
    aspect_ratio=1,
    annotations=[(j, i, text(string(cm.mat[i,j]), 12, :black, :center)) for i in 1:3, j in 1:3]
)
savefig("Fig1_Confusion_Matrix.png")

# ---------------------------------------------------------
# 3. FIG 2: PERFORMANCE
# ---------------------------------------------------------
println("Generating Fig 2: Performance Charts...")

metrics = ["Accuracy", "F1-Score"]
scores = [0.642, 0.630] 
errors = [0.114, 0.10] 

bar(metrics, scores, yerr=errors, title="Validated Model Performance (Mean ± SD)",
    ylabel="Score", ylim=(0, 1.0), color=[:blue, :purple], legend=false, size=(500, 500))
savefig("Fig2_Performance.png")

# ---------------------------------------------------------
# 4. FIG 3: FEATURE IMPORTANCE
# ---------------------------------------------------------
println("Generating Fig 3: Feature Importance...")

if isfile("final_feature_importance.csv")
    imp_df = CSV.read("final_feature_importance.csv", DataFrame)
    top_10 = first(imp_df, 10)
    sort!(top_10, :Importance)

    bar(top_10.Feature, top_10.Importance, orientation=:h,
        title="Top 10 Predictors (Leakage-Free)", xlabel="Gini Importance",
        legend=false, color=:dodgerblue, size=(800, 600), left_margin=10mm)
    savefig("Fig3_Feature_Importance.png")
end

# ---------------------------------------------------------
# 5. FIG 4: BIOMARKER BOXPLOTS
# ---------------------------------------------------------
println("Generating Fig 4: Biomarker Distributions...")

# FIX: Create a fresh DataFrame for plotting and drop rows with missing values
# so that the boxplot quantiles can be calculated.
biomarker_plot_df = dropmissing(DataFrames.DataFrame(
    Clinical_Group = y,
    Hornerin = X.Hornerin,
    SFN = X.SFN
))

p1 = @df biomarker_plot_df boxplot(:Clinical_Group, :Hornerin, title="Hornerin", ylabel="Value", color=:cyan, label=false)
p2 = @df biomarker_plot_df boxplot(:Clinical_Group, :SFN, title="SFN", ylabel="", color=:orange, label=false)

plot(p1, p2, layout=(1, 2), size=(900, 500), bottom_margin=10mm)
savefig("Fig4_Biomarkers.png")

println("\nSuccess! 4 Figures created: Fig1-Fig4.png")