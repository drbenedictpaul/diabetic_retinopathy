using DataFrames
using CSV
using HypothesisTests
using MultipleTesting
using Statistics
using StatsBase
using Distributions

println("Loading data for statistical analysis...")
# Load the cleaned data
data = CSV.read("diabetic_retinopathy_ready_for_pipeline.csv", DataFrame, 
                missingstring=["", "missing", "NaN", "nan", "NA", "Nil", "-"])

# Drop missing values specifically for the biomarkers
clean_data = dropmissing(data, [:Hornerin, :SFN, :Clinical_Group])

# --- YOUR ACTUAL CSV DATA LABELS ---
g1_data = "DM (Disease Control)"
g2_data = "DR (Retinopathy)"
g3_data = "Combined DR+DN"

# --- DISPLAY LABELS FOR YOUR MANUSCRIPT ---
g1_disp = "T2DM"
g2_disp = "DR only"
g3_disp = "DR with DN"

# --- HELPER FUNCTIONS ---

# 1. Cliff's Delta
function cliffs_delta(x, y)
    n_x = length(x)
    n_y = length(y)
    dom_x_y = sum(i > j for i in x, j in y)
    dom_y_x = sum(i < j for i in x, j in y)
    return (dom_x_y - dom_y_x) / (n_x * n_y)
end

# 2. Kruskal-Wallis Eta-Squared
function kw_eta_squared(H, k, n)
    return (H - k + 1) / (n - k)
end

# 3. Dunn's Test (with Tie Correction)
function dunn_test(x1, x2, x3)
    n1, n2, n3 = length(x1), length(x2), length(x3)
    N = n1 + n2 + n3
    
    # Pool and rank data
    all_data = vcat(x1, x2, x3)
    ranks = tiedrank(all_data)
    
    # Calculate Mean Ranks for each group
    R1 = mean(ranks[1:n1])
    R2 = mean(ranks[n1+1 : n1+n2])
    R3 = mean(ranks[n1+n2+1 : N])
    
    # Variance with tie correction
    tie_counts = values(countmap(all_data))
    tie_adj = sum(t^3 - t for t in tie_counts) / (12 * (N - 1))
    V = (N * (N + 1) / 12) - tie_adj
    
    # Standard Errors for each pair
    se_12 = sqrt(V * (1/n1 + 1/n2))
    se_13 = sqrt(V * (1/n1 + 1/n3))
    se_23 = sqrt(V * (1/n2 + 1/n3))
    
    # Z-scores
    z_12 = abs(R1 - R2) / se_12
    z_13 = abs(R1 - R3) / se_13
    z_23 = abs(R2 - R3) / se_23
    
    # Two-tailed p-values
    dist = Normal(0, 1)
    p_12 = 2 * (1 - cdf(dist, z_12))
    p_13 = 2 * (1 - cdf(dist, z_13))
    p_23 = 2 * (1 - cdf(dist, z_23))
    
    return [p_12, p_13, p_23]
end

# --- RUN ANALYSIS ---

biomarkers = [:Hornerin, :SFN]

for bm in biomarkers
    println("\n========================================")
    println("STATISTICAL ANALYSIS FOR: ", bm)
    println("========================================")
    
    # Extract arrays using the raw CSV labels
    x1 = Float64.(clean_data[clean_data.Clinical_Group .== g1_data, bm])
    x2 = Float64.(clean_data[clean_data.Clinical_Group .== g2_data, bm])
    x3 = Float64.(clean_data[clean_data.Clinical_Group .== g3_data, bm])
    
    n_total = length(x1) + length(x2) + length(x3)
    
    if n_total == 0
        println("ERROR: No data found. Check your CSV group names.")
        continue
    end
    
    # 1. KRUSKAL-WALLIS TEST
    kw_test = KruskalWallisTest(x1, x2, x3)
    p_kw = pvalue(kw_test)
    H_stat = kw_test.H  # FIX: Used .H instead of .chi2
    eta2 = kw_eta_squared(H_stat, 3, n_total)
    
    println("1. Global Kruskal-Wallis Test")
    println("   p-value:      ", round(p_kw, digits=5))
    println("   H-Statistic:  ", round(H_stat, digits=3))
    println("   Effect Size (η²): ", round(eta2, digits=3))
    
    # 2. DUNN'S TEST WITH HOLM CORRECTION
    println("\n2. Post-Hoc Pairwise Testing (Dunn's Test with Holm correction)")
    
    raw_pvals = dunn_test(x1, x2, x3)
    adj_pvals = adjust(raw_pvals, Holm()) # Holm-Bonferroni correction
    
    # Calculate Cliff's Delta
    cd_12 = cliffs_delta(x1, x2)
    cd_13 = cliffs_delta(x1, x3)
    cd_23 = cliffs_delta(x2, x3)
    
    # Print using the display labels
    pairs = [
        ("$g1_disp vs $g2_disp", raw_pvals[1], adj_pvals[1], cd_12),
        ("$g1_disp vs $g3_disp", raw_pvals[2], adj_pvals[2], cd_13),
        ("$g2_disp vs $g3_disp", raw_pvals[3], adj_pvals[3], cd_23)
    ]
    
    for (pair_name, p_raw, p_adj, cd) in pairs
        println("   Comparison: ", pair_name)
        println("     Raw p-value:  ", round(p_raw, digits=4))
        println("     Adj p-value:  ", round(p_adj, digits=4))
        println("     Cliff's Delta:", round(cd, digits=3))
        println("     ---")
    end
end
println("\nAnalysis Complete.")