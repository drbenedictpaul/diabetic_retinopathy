# Import the necessary packages
using CSV
using DataFrames

# Specify the path to your CSV file
# (Can be a relative path like this, or an absolute path like "/home/user/data/my_data.csv")
filepath = "diabetic_retinopathy.csv"

try
    # Read the CSV file into a DataFrame
    # CSV.read automatically handles headers and tries to infer data types.
    # It also recognizes standard missing values (like the empty field for Charlie).
    df = CSV.read(filepath, DataFrame)

    # Print the DataFrame to see the contents
    println("Successfully read CSV into DataFrame:")
    println(df)

    # You can now work with the DataFrame 'df'
    println("\nAccessing data:")
    println("Value for Bob: ", df[df.Name .== "Bob", :Value][1]) # Example access
    println("Data Types of columns:")
    println(eltype.(eachcol(df))) # Show inferred types per column

catch e
    println("Error reading CSV file: ", filepath)
    showerror(stdout, e)
    println()
end