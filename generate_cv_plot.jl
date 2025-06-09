using Plots
using CSV
using DataFrames

# Load cv_results.csv
cv_results = CSV.read("cv_results.csv", DataFrame)

# Verify DataFrame structure
println("cv_results DataFrame:")
println(cv_results)

# Extract per-fold metrics as vectors
folds = Vector{Int}(cv_results.Fold)
acc = Vector{Float64}(cv_results.Accuracy)
prec = Vector{Float64}(cv_results.Precision)
rec = Vector{Float64}(cv_results.Recall)
f1 = Vector{Float64}(cv_results.F1_Score)

# Create grouped bar plot
bar_width = 0.2
p = bar(folds .- 1.5*bar_width, acc, width=bar_width, label="Accuracy", color=:blue)
bar!(folds .- 0.5*bar_width, prec, width=bar_width, label="Precision", color=:red)
bar!(folds .+ 0.5*bar_width, rec, width=bar_width, label="Recall", color=:green)
bar!(folds .+ 1.0*bar_width, f1, width=bar_width, label="F1-Score", color=:purple)

plot!(title="5-Fold Cross-Validation Performance", xlabel="Fold", ylabel="Score",
      legend=:topleft, size=(800, 600), dpi=300, xticks=1:5)

# Save plot
savefig("cv_performance_plot.png")
println("Saved CV performance plot to cv_performance_plot.png")