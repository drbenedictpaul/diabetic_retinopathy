using Plots
using DataFrames
using CSV
using Measures
using StatsPlots

# Suppress Qt warning by setting backend to GR explicitly
ENV["GKSwstype"] = "nul"
gr(size=(1000, 600))

# Load the preprocessed dataset (adjust path if needed)
data = CSV.read("diabetic_retinopathy_preprocessed.csv", DataFrame)

# Create box plot for Hornerin and SFN with proper axis titles and legend
p1 = boxplot([data[data[!, :Clinical_Group] .== "DM", :Hornerin], 
              data[data[!, :Clinical_Group] .== "DR", :Hornerin], 
              data[data[!, :Clinical_Group] .== "DN", :Hornerin]], 
             xticks=([1, 2, 3], ["DM", "DR", "DN"]), 
             xlabel="Clinical Group", 
             ylabel="Hornerin (standardized)", 
             label=["DM" "DR" "DN"], 
             titlefont=font(14), 
             guidefont=font(12), 
             tickfont=font(10), 
             legend=:topright, 
             margin=5mm)
p2 = boxplot([data[data[!, :Clinical_Group] .== "DM", :SFN], 
              data[data[!, :Clinical_Group] .== "DR", :SFN], 
              data[data[!, :Clinical_Group] .== "DN", :SFN]], 
             xticks=([1, 2, 3], ["DM", "DR", "DN"]), 
             xlabel="Clinical Group", 
             ylabel="SFN (standardized)", 
             label=["DM" "DR" "DN"], 
             titlefont=font(14), 
             guidefont=font(12), 
             tickfont=font(10), 
             legend=:topright, 
             margin=5mm)

combined_plot = plot(p1, p2, 
                     layout=(1, 2), 
                     top_margin=40mm,  # Increased margin to ensure title separation
                     title="Biomarker Distribution Across Clinical Groups", 
                     titlefont=font(16), 
                     title_location=:center)
# Save plot with high resolution
savefig(combined_plot, "biomarker_boxplot.png")
println("Saved biomarker boxplot to biomarker_boxplot.png")