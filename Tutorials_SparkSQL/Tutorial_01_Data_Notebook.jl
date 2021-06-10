### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# ╔═╡ d3fd503e-ee83-4784-9e1e-48ce486e96d7
using SparkSQL

# ╔═╡ 0cddf535-f9ba-4671-852e-7bfa6c027259
using DataFrames, Decimals, Dates

# ╔═╡ a2916264-5da9-4fee-b528-d39f6ac3dff1
SparkSQL.initJVM()

# ╔═╡ bb8df7fc-c778-4091-b809-dfad5a6be414
sprk = SparkSQL.SparkSession("spark://localhost:7077", "Julia Lang Spark App");

# ╔═╡ b44aef6c-5a0c-4cae-896b-2f2ce4bd403a
############################################################################
#
# Lesson 1:
#
# Convert a CSV file to Parquet format with Apache Spark from Julia.
#
############################################################################

# ╔═╡ d45d1b01-404a-40b3-894b-e37407b464e8
# Step 1:  Read the CSV file using SQL. Cast (convert) the values to the correct data types. The CSV file is also missing column headers so we assign column names.

# ╔═╡ 113e3688-d972-46dd-b324-5ed9a71853ca
CSVdata = sql(sprk, "SELECT _c0 AS TICKER, to_date(_c1, 'yyyymmdd') AS TRADING_DATE, CAST(_c5 AS double) AS CLOSE FROM CSV.`/tmp/sampleData.csv`;");

# ╔═╡ 6179c4a4-5922-493e-b44b-96497fe66c35
# Step 2: Create a temporary database view in order to be able refer to the data using SQL.  In this example, the view name will be "stocks".

# ╔═╡ 3a091694-5c2a-4546-883f-0de0d0700736
createOrReplaceTempView(CSVdata, "stocks");

# ╔═╡ 343a7cd4-0ed3-475b-bfae-9d0d36e7b477
# Step 3: Use SQL to create a new Parquet file in the user specified location.

# ╔═╡ 190db402-8012-4873-b2ce-e48750bb0a8f
createFile = sql(sprk, "CREATE TABLE IF NOT EXISTS stocksFile USING PARQUET LOCATION '/tmp/stocks.PARQUET' AS SELECT * FROM stocks;")

# ╔═╡ 45a048a5-811f-43a0-b0ff-451b060022eb
############################################################################
#
# Lesson 2:
#
# Using Apache Spark and Julia data together.
#
############################################################################

# ╔═╡ 2639ef0d-53aa-4775-972f-991341f6a528
# How to query Apache Spark from Julia

# ╔═╡ 0f10e1fe-4d94-4656-a833-b78ca1bb809e
sparkQuery = sql(sprk, "SELECT * FROM stocks;")

# ╔═╡ e47fa0c2-1d26-41a8-9852-02976aa30590
# How to move Apache Spark DataSets to a Julia DataFrames:

# Use the SparkSQL.jl "toJuliaDF" function to bring Spark data into a Julia DataFrame. SparkSQL.jl creates the Julia DataFrame with the correct data types and column names automatically.

# ╔═╡ 833d323d-3944-4368-ac17-8bdd25692130
fromSparkToJulia = toJuliaDF(sparkQuery)

# ╔═╡ 8f9ee109-cfc7-4191-8cf4-611434895bde
# Create a Julia DataFrame

# ╔═╡ efcb9465-9fdd-4a87-9375-435ff2df2512
JuliaDataFrame = DataFrame(tickers = ["CRM", "IBM"])

# ╔═╡ 00062b98-5a98-45b6-9985-ed8016a01505
# How to move Julia DataFrames to Apache Spark DataSets.

# Use the SparkSQL.jl "toSparkDS" function to move that Julia DataFrame to a new Apache Spark DataSet.

# ╔═╡ 525b9215-c6c0-4079-9239-71c19bf96b61
movetoSpark = toSparkDS(sprk, JuliaDataFrame)

# ╔═╡ fc0c9c17-9a7a-435e-87ac-53bed8015b7f
# Create a database view in Spark for Julia DataFrame Data.

# ╔═╡ bade3add-f080-4dd2-b3e4-726e30d060d5
createOrReplaceTempView(movetoSpark, "julia_data")

# ╔═╡ 40680e7f-24d0-417b-9f2a-78086d84404c
# How to query Apache Spark and Julia data using SQL.

# Example query shows how to filter the stocks view with a subselect on julia data.

# ╔═╡ 0c2abeda-d5dc-4f59-a1c0-337f33396a47
chainSparkAndJuliaData = sql(sprk, "SELECT * FROM stocks WHERE TICKER IN (SELECT split(value, ',' )[0] AS tickers FROM julia_data)")

# ╔═╡ 02758b94-b949-4fc0-8ce9-5205ace25096
# Bring the results back from Spark to a Julia DataFrame. 

# ╔═╡ 0a2eb12b-8680-49e7-9772-3b5ba49a2a2b
chainedData = toJuliaDF(chainSparkAndJuliaData)

# ╔═╡ ea3b1579-1e75-4c95-ba2e-9374f7265d35
# The results show only CRM and IBM ticker data.  Signifying the subquery worked.

# ╔═╡ e78c7b62-3dbd-43a0-972c-bbde2e3051e1
describe(chainedData)

# ╔═╡ Cell order:
# ╠═d3fd503e-ee83-4784-9e1e-48ce486e96d7
# ╠═a2916264-5da9-4fee-b528-d39f6ac3dff1
# ╠═bb8df7fc-c778-4091-b809-dfad5a6be414
# ╠═b44aef6c-5a0c-4cae-896b-2f2ce4bd403a
# ╠═d45d1b01-404a-40b3-894b-e37407b464e8
# ╠═113e3688-d972-46dd-b324-5ed9a71853ca
# ╠═6179c4a4-5922-493e-b44b-96497fe66c35
# ╠═3a091694-5c2a-4546-883f-0de0d0700736
# ╠═343a7cd4-0ed3-475b-bfae-9d0d36e7b477
# ╠═190db402-8012-4873-b2ce-e48750bb0a8f
# ╠═45a048a5-811f-43a0-b0ff-451b060022eb
# ╠═0cddf535-f9ba-4671-852e-7bfa6c027259
# ╠═2639ef0d-53aa-4775-972f-991341f6a528
# ╠═0f10e1fe-4d94-4656-a833-b78ca1bb809e
# ╠═e47fa0c2-1d26-41a8-9852-02976aa30590
# ╠═833d323d-3944-4368-ac17-8bdd25692130
# ╠═8f9ee109-cfc7-4191-8cf4-611434895bde
# ╠═efcb9465-9fdd-4a87-9375-435ff2df2512
# ╠═00062b98-5a98-45b6-9985-ed8016a01505
# ╠═525b9215-c6c0-4079-9239-71c19bf96b61
# ╠═fc0c9c17-9a7a-435e-87ac-53bed8015b7f
# ╠═bade3add-f080-4dd2-b3e4-726e30d060d5
# ╠═40680e7f-24d0-417b-9f2a-78086d84404c
# ╠═0c2abeda-d5dc-4f59-a1c0-337f33396a47
# ╠═02758b94-b949-4fc0-8ce9-5205ace25096
# ╠═0a2eb12b-8680-49e7-9772-3b5ba49a2a2b
# ╠═ea3b1579-1e75-4c95-ba2e-9374f7265d35
# ╠═e78c7b62-3dbd-43a0-972c-bbde2e3051e1
