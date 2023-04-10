### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ b7474933-2748-4a7d-8e82-f7371f88ab57
using SparkSQL, DataFrames, Decimals, Dates

# ╔═╡ 929930ba-fb2c-4dbd-9d83-2dcb4cbfc8b5
using AlphaVantage

# ╔═╡ f8961d47-b607-4cf2-9306-d15ebd904227
using StatsPlots

# ╔═╡ ddf4d984-19e0-4e11-9484-0658e55612e0
using PlutoUI

# ╔═╡ e17d4f40-7da1-422e-9a59-e698e351f377
################################################################################
# 
#
# Learn how to:
# 1.) Setup Julia to work with Apache Spark and Delta Lake
# 2.) Create databasess, tables, views and perform common operations in Data Lakes.
# 3.) Use Julia DataFrames with Apache Spark and Delta Lake.
# 4.) Plot DataFrame data in Julia.
# 5.) Plot multiple data series to a single chart.
# 6.) Build user interfaces (menus, input boxes) with Julia Pluto notebooks.
# 7.) Call APIs to obtain external data.
# 8.) Save data to Apache Spark and Delta lake.

################################################################################

# ╔═╡ c33b289e-93ce-464a-96c7-50e5ca6aa902
# SparkSQL and DataFrames packages are required; Decimals, and Dates are needed if those types are present in your data.

# ╔═╡ ea16757d-4ead-4b1b-99de-1ee182da2ba5
# Use initJVM to initialize the Java Virtual Machine.

# ╔═╡ 4484cdc9-81bb-432d-8fe0-a49c6eebd472
SparkSQL.initJVM()

# ╔═╡ 1885f735-a94e-4f62-9ee8-b8d14817415a
# SparkSession is the entry point to using the Apache Spark Dataset & Dataframe API. Pass the the url for Spark, and your app name as arguments.  

# This tutorial shows how to use Apache Spark Delta Lake and Julia.

# ╔═╡ 655f696c-b948-47eb-8f9e-a8ce327e251d
# The SparkSession function accepts additional arguments as a dictionary.  We add the Delta lake settings.  Please note that you need to add the delta lake jar to your Spark jars folder. 

# ╔═╡ e1d761be-9774-45f7-ad42-2197065dd9f4
# The spark.sql.warehouse.dir is the path were Spark stores Delta lake data.

# ╔═╡ cbf8ab8b-2ff4-4071-88b8-540d0cef9ba9
#sprk = SparkSQL.SparkSession("spark://localhost:7077", "Julia Spark Stock App", Dict{String, String}("spark.sql.warehouse.dir"=>"/tmp/stockdb","spark.sql.extensions"=>"io.delta.sql.DeltaSparkSessionExtension","spark.sql.catalog.spark_catalog"=>"org.apache.spark.sql.delta.catalog.DeltaCatalog"));

# ╔═╡ 6c9506d6-d81e-4905-980d-a3bbf99c0442
sprk = SparkSQL.SparkSession("spark://localhost:7077", "Julia Spark Stock App", Dict{String,String}("spark.sql.warehouse.dir"=>"/tmp/stockdb", "spark.sql.extensions"=>"io.delta.sql.DeltaSparkSessionExtension", "spark.sql.catalog.spark_catalog"=>"org.apache.spark.sql.delta.catalog.DeltaCatalog"));

# ╔═╡ e32df0fe-7fc1-4c6b-bb5f-44aaf20960f3
# Set Apache Spark to use Delta Database.

# ╔═╡ 4e3b4041-62a2-444d-b552-0e6e62d43cf3
# Create a database called "dbo".

# ╔═╡ 2efcacce-b8db-4dcc-8c9d-9cffa4748ca9
createDatabase = sql(sprk, "CREATE DATABASE IF NOT EXISTS dbo")

# ╔═╡ 309d6a20-8d69-4893-85bc-1273d7ad72a4
# Set the current database to "dbo"

# ╔═╡ 72f7cdec-5a1c-451f-a9c5-ce35204237af
currentDatabase = sql(sprk, "USE dbo;")

# ╔═╡ 4d5c9279-e0c3-4b24-9415-c8884e25a9e1
# Describe the dbo database.

# ╔═╡ f4f89dd8-0588-4694-8bb8-27fe619dd5f6
databaseInfo = sql(sprk, "DESCRIBE DATABASE dbo;")

# ╔═╡ 790debfb-9516-429b-94b6-c007a58b0d88
getDatabaseDetails = toJuliaDF(databaseInfo)

# ╔═╡ 3d3bc919-8987-47ee-8270-d77d249a9926
# Build Stock market application to show SparkSQL.jl an dJulia concepts.

# ╔═╡ 663acfb7-ae5a-4a73-8808-322bdc8d29ca
# The tutorial gets stock data via the AlphaVantage API.  Get your API before running.

# ╔═╡ 0ec9de7f-b638-4328-bd97-a3fa640b6306
# Set the AlphaVantage API key in the shell prompt:
# export ALPHA_VANTAGE_API_KEY=YOUR_API_KEY
# -OR- in Julia
# ENV["ALPHA_VANTAGE_API_KEY"]="your_API_key"

# ╔═╡ e3f50faf-3958-4c4b-9513-52fdf480efb5
 # AlphaVantage.global_key!("YOUR_API_KEY");

# ╔═╡ f84a8b42-7b14-43ce-bcd3-2e14ab8d2dd9
# Call the API to get the full history of IBM stock by calling the time_series_daily_adjusted API:

# ╔═╡ e55be7da-3e4d-4be1-853c-fea592252656
stockAPIResults = time_series_daily_adjusted("IBM", outputsize="full", datatype="csv")

# ╔═╡ a4457433-ecd2-434b-9ded-602a9c84c8a2
stockDataFrame = DataFrame(stockAPIResults[1])

# ╔═╡ b6fb22d3-a1c4-468b-b5d6-28a9a9080816
# The column header names are in the second matrix returned by the API.
# Set column headers for the Julia DataFrame.

# ╔═╡ 31adb6a1-f0fe-49d6-8354-41867501d5cb
ibmDataFrame = rename(stockDataFrame, Symbol.(vcat(stockAPIResults[2]...)))

# ╔═╡ 7b35c53b-932c-44c7-8997-1a04a406e6b6
# Set Data Types in the Julia DataFrame.

# ╔═╡ e11ac344-8c98-4c8a-bfd1-febc9f23ea31
begin
	ibmDataFrame[!, :timestamp] = Dates.DateTime.(ibmDataFrame[!, :timestamp],
	dateformat"yyyy-mm-dd HH:MM:SS")
	ibmDataFrame[!, :open] = Float64.(ibmDataFrame[!, :open])
	ibmDataFrame[!, :high] = Float64.(ibmDataFrame[!, :high])
	ibmDataFrame[!, :low] = Float64.(ibmDataFrame[!, :low])
	ibmDataFrame[!, :close] = Float64.(ibmDataFrame[!, :close])
	ibmDataFrame[!, :adjusted_close] = Float64.(ibmDataFrame[!, :adjusted_close])
	ibmDataFrame[!, :volume] = Integer.(ibmDataFrame[!, :volume])
end

# ╔═╡ 77d13717-42e5-41de-ba42-aca96e9256bc
# Add StatsPlots package to plot data.

# ╔═╡ 370a30e5-4ccd-4dd3-b90c-d57a2dc23dc8
plot(ibmDataFrame[!,:timestamp], ibmDataFrame[!, :adjusted_close],label="IBM Adjusted Close Price", legend=:topleft)

# ╔═╡ 7c7638de-d71e-4d11-957f-165b01915e48
# Plot multiple series on one chart.

# ╔═╡ 076a56cc-eab4-4dd0-8429-d98acdc139cd
# Plot compares the adjusted close price with the close price.

# ╔═╡ c13b4535-d5ee-40d5-99cc-067b016a6634
begin
@df ibmDataFrame density(:adjusted_close, label="IBM ajusted Close", legend=:topright)
@df ibmDataFrame density!(:close, label="IBM Close", legend=:topright)	
end

# ╔═╡ 5d0e1bdd-9e4c-48fc-b30d-93fe106f2f7f
# The PlutoUI package provides support for creating user interface.

# ╔═╡ c7a9e6a6-e3b9-4f17-9553-04900cf6c8d4
md"""
Filter stock ticker data by start date:
- Date: $(@bind filterbyDate TextField())
"""

# ╔═╡ b1e8ae96-c484-4fb4-8517-3ceb4955b107
# Sleep for 1 minute to allow time for selection data entry.

# ╔═╡ 4bd7a153-2a62-4250-bbf6-2a91e4228458
sleep(60)

# ╔═╡ 68022e23-64ef-412c-b3bd-abdb70c0da3c
# Apply the DataFrame filter function on the date field.

# ╔═╡ df5037f8-070d-4e65-a59f-6070a8e0427e
filteredTicker = filter( row -> row.timestamp >= Dates.Date(filterbyDate,dateformat"yyyy-mm-dd"), ibmDataFrame)

# ╔═╡ 64710502-ebf6-4081-9cc7-91b4eeced20a
# Plot the filtered data.

# ╔═╡ 7fa93a21-2b08-4a9a-86b3-da2f4e660b27
plot(filteredTicker[!,:timestamp],filteredTicker[!, :adjusted_close], label="Date Filtered IBM Adjusted Close", legend=:bottomleft)

# ╔═╡ 086c1a13-c125-4a9a-bf32-4721e3da05f7
# Pick stocks to compare.

# ╔═╡ 37061040-69ae-44aa-9e9d-3c8ff8c8b478
md"""
Compare two stock tickers:

- Ticker one: $(@bind stockTicker1 Select(["AAPL", "AMZN", "TSLA", "GOOG"]))
- Ticker two: $(@bind stockTicker2 Select(["AAPL", "AMZN", "TSLA", "GOOG"]))
"""

# ╔═╡ 980d1c7b-2a18-41c4-aba3-b8fde3d8eb43
sleep(60)

# ╔═╡ 78cfe580-0005-445e-b5f1-866dbedc4e9e
# Get company information for the first ticker we selected with the company_overview API:

# ╔═╡ 1427e80a-8d7a-41ec-800e-602af22c3e38
stockOverview1 = company_overview(stockTicker1)

# ╔═╡ 908f2a04-60ad-48a0-81d9-4666877e8302
# Return the address of the company from the Ticker:
# You can change the Key to view the other properties of the ticker.

# ╔═╡ 7e322413-2ce4-4c63-a585-2371947d70a2
stockOverview1["Address"]

# ╔═╡ 3ced9c4b-ead8-4f6c-a8a5-c36edf863508
# View teh terminal output using the with_terminal function.

# ╔═╡ 71c48042-3df6-45f1-a133-fed42448f805
with_terminal(println,stockTicker1)

# ╔═╡ 75cf6914-2a55-437f-b1f6-ace0a1ac1c28
# Get data for ticker1:

# ╔═╡ 498bec6f-7035-4e59-995a-92c62bdbe4c7
getTicker1 = time_series_daily_adjusted(stockTicker1, outputsize="full", datatype="csv")

# ╔═╡ 948b812e-438f-4b7a-9978-a445245271c9
# Set column headers and cast data types for ticker1:

# ╔═╡ 6ff5c526-5526-4642-a886-7b86dce0eb98
begin
	dfa = DataFrame(getTicker1[1]);
	tickerOneDF = rename(dfa, Symbol.(vcat(getTicker1[2]...)));
	tickerOneDF[!, :timestamp] = Dates.DateTime.(tickerOneDF[!, :timestamp], dateformat"yyyy-mm-dd HH:MM:SS");
	tickerOneDF[!, :open] = Float64.(tickerOneDF[!, :open]);
	tickerOneDF[!, :high] = Float64.(tickerOneDF[!, :high]);
	tickerOneDF[!, :low] = Float64.(tickerOneDF[!, :low]);
	tickerOneDF[!, :close] = Float64.(tickerOneDF[!, :close]);
	tickerOneDF[!, :volume] = Integer.(tickerOneDF[!, :volume]);
	tickerOneDF[!, :adjusted_close] = Float64.(tickerOneDF[!, :adjusted_close]);
end

# ╔═╡ 2f6773bd-4a7a-433e-9264-ce8775025ea4
# Get data for ticker2:

# ╔═╡ 5f82ca74-c155-4927-ab13-a3c909aeb5e4
getTicker2 = time_series_daily_adjusted(stockTicker2, outputsize="full", datatype="csv")

# ╔═╡ a1d8425d-1756-4bd0-86bc-092996f34ada
# Set column headers and cast data types for ticker2:

# ╔═╡ b97e8c3c-dd05-40be-a1ab-ea59e3047c97
begin
	dfb = DataFrame(getTicker2[1]);
	tickerTwoDF = rename(dfb, Symbol.(vcat(getTicker2[2]...)));
	tickerTwoDF[!, :timestamp] = Dates.DateTime.(tickerTwoDF[!, :timestamp], dateformat"yyyy-mm-dd HH:MM:SS");
	tickerTwoDF[!, :open] = Float64.(tickerTwoDF[!, :open]);
	tickerTwoDF[!, :high] = Float64.(tickerTwoDF[!, :high]);
	tickerTwoDF[!, :low] = Float64.(tickerTwoDF[!, :low]);
	tickerTwoDF[!, :close] = Float64.(tickerTwoDF[!, :close]);
	tickerTwoDF[!, :volume] = Integer.(tickerTwoDF[!, :volume]);
	tickerTwoDF[!, :adjusted_close] = Float64.(tickerTwoDF[!, :adjusted_close]);
end

# ╔═╡ bd5fc46f-2b54-4aa0-8fcc-336c4011594f
# Chart ticker1 and ticker2.

# Notice that the "!" character is requried in subsequent plot commands to have additional series appear on the same chart. e.g. plog(tickerOneDF ... vs plot!(tickerTwoDF ...

# ╔═╡ f254852e-7edb-4fb4-8fa8-ab0409476282
begin
	
plot(tickerOneDF[!,:timestamp], tickerOneDF[!, :adjusted_close],label=stockTicker1, legend=:topleft);
	
plot!(tickerTwoDF[!,:timestamp], tickerTwoDF[!, :adjusted_close],label=stockTicker2, legend=:topleft);
	
end

# ╔═╡ fbbbf550-7f80-4dd9-8afc-e615d78655ab
# Move Stock Data to Spark via SparkSQL.jl toSparkDS function.

# ╔═╡ e3b62586-b24c-4289-bf50-4e11113d367a
stockupload = toSparkDS(sprk,tickerOneDF)

# ╔═╡ a98720b6-c002-42d9-940f-4d80cc324208
# Create Temp View in Spark using ticker name.

# ╔═╡ a69791d9-8e94-4c1d-944d-dea62960abbd
createOrReplaceTempView(stockupload, stockTicker1)

# ╔═╡ 47ee8744-70dd-4783-be00-8768349c6b90
etlSplitColumnQuery = sql(sprk, "SELECT
	split(value, ',')[0] AS trade_date,
	split(value, ',')[1] AS open,
	split(value, ',')[2] AS high,
	split(value, ',')[3] AS low,
	split(value, ',')[4] AS close,
	split(value, ',')[5] AS adjusted_close,
	split(value, ',')[6] AS volume,
	split(value, ',')[7] AS dividend_amount,
	split(value, ',')[8] AS split_coefficient

	FROM $stockTicker1"
	)

# ╔═╡ f4b52e3f-d15f-4b26-a2fe-2b590286b9f9
# Save the split columns as a database view.

# ╔═╡ 327b2c85-6b92-42e5-aace-8ae9a004a967
createOrReplaceTempView(etlSplitColumnQuery, "etl_$stockTicker1")

# ╔═╡ 8fcd6911-c296-4d49-9af3-8a51d6c9ae6c
# Cast the columns to the appropriate datatype. Use string interpolation to add in Ticker name.

# ╔═╡ f1c9dc95-6d75-48ca-981d-61d9ce966a5d
etlCastDataTypesQuery = sql(sprk, "SELECT
	'$stockTicker1' AS ticker,
	to_date(substr(trade_date, 1, 10), 'yyyy-mm-dd') trade_date,
	cast(open AS double) open,
	cast(high AS double) high,
	cast(low AS double) low,
	cast(close AS double) close,
	cast(adjusted_close AS double) adjusted_close,
	cast(volume AS integer) volume,
	cast(dividend_amount AS double) dividend_amount,
	cast(split_coefficient AS double) split_coefficient
	FROM etl_$stockTicker1")

# ╔═╡ a4b785e0-3ce4-433f-a976-7bff116b3ecc
# Create temp table

# ╔═╡ b090865b-a580-4ccc-9737-8fa35c09bd4c
createOrReplaceTempView(etlCastDataTypesQuery, "persist_$stockTicker1")

# ╔═╡ 6f7aa5ce-f974-4af6-b8e3-37e3f90201ee
# Storing Data in Parquet format enables faster performance for analytic queries.

# ╔═╡ 6843a0e3-5c74-43cf-8b30-3f6b533b0177
# Save to Parquet format:

# ╔═╡ 10338d9e-bb9b-4971-97df-807fd8875e49
saveToDisk = sql(sprk,"CREATE TABLE IF NOT EXISTS stocks LIKE persist_$stockTicker1 STORED AS PARQUET;")

# ╔═╡ 40096ec8-b9ec-4dae-8107-3f6f6ca0552b
# Insert stock data into Parquet table.

# ╔═╡ c3cba41f-3bd4-433c-8f14-5b0e1b34f3e2
sql(sprk,"INSERT INTO dbo.Stocks SELECT * FROM persist_$stockTicker1")

# ╔═╡ f1935958-d269-4b66-bed5-6e3f71629fc3
# Delta adds ACID transaction support to Parquet.  Build Lakehouse architecture with Delta Lake.

# ╔═╡ 58e2f746-350c-480e-8079-45179b0e5a64
# Save to Delta format: (Note: define table manually becaue CREATE TABLE LIKE syntax is not supported with Delta).

# ╔═╡ 29b533f5-32ca-4d7c-9469-83c4add9d3d6
saveToDelta = sql(sprk, "CREATE TABLE IF NOT EXISTS
	stocksdelta
	(
        ticker STRING,
		trade_date DATE,
		open DOUBLE,
		high DOUBLE,
		low DOUBLE,
		close DOUBLE,
		adjusted_close DOUBLE,
		volume INTEGER,
		dividend_amount DOUBLE,
		split_coefficinet DOUBLE
	
	 ) USING DELTA;")

# ╔═╡ fb7fb3f4-3eae-446e-9a56-3b75077df73f
# Insert stock data into Delta table.

# ╔═╡ d9543aa8-afc9-4d97-83f9-30c25b773848
sql(sprk, "INSERT INTO dbo.stocksdelta SELECT * FROM persist_$stockTicker1")

# ╔═╡ 6dbe5647-bd75-48c2-b6e8-3de5634b2b5e
# Query the Delta Table

# ╔═╡ 8e7add5c-cbd0-481a-b059-18653aa5ef5a
queryDeltaTable = sql(sprk, "SELECT * FROM dbo.stocksdelta")

# ╔═╡ e38d2f6e-9922-4c53-80df-1788a1f45f5d
# Get data into Julia DataFrame from an Apache Spark Delta table.

# ╔═╡ bd32f7a6-6fc9-4a04-9b6e-147308c714da
deltaTableData = toJuliaDF(queryDeltaTable)

# ╔═╡ 9e23601c-c78a-4fdd-8cb6-575bdf86ff85
# View tables in dbo Database.

# ╔═╡ 8b4f8cc8-f3bf-4531-ae7f-275b51b65988
databaseSchema = sql(sprk,"SHOW TABLES;")

# ╔═╡ 2cf7067f-8307-423c-9d21-1e3fb3ca59c1
dfSchema = toJuliaDF(databaseSchema)

# ╔═╡ 1c6f7c98-cde4-432d-b97c-cf8167072018
# Congrats!  You learned how to setup Julia to work with Apache Spark and Delta Lake.  You are able to create databases, tables, views, and perform common Spark operations from within Julia lang.

# Additionally you learned how to build user interface elements, plot datafram series on charts and call external APIs in Julia.



# ╔═╡ Cell order:
# ╠═e17d4f40-7da1-422e-9a59-e698e351f377
# ╠═c33b289e-93ce-464a-96c7-50e5ca6aa902
# ╠═b7474933-2748-4a7d-8e82-f7371f88ab57
# ╠═ea16757d-4ead-4b1b-99de-1ee182da2ba5
# ╠═4484cdc9-81bb-432d-8fe0-a49c6eebd472
# ╠═1885f735-a94e-4f62-9ee8-b8d14817415a
# ╠═655f696c-b948-47eb-8f9e-a8ce327e251d
# ╠═e1d761be-9774-45f7-ad42-2197065dd9f4
# ╠═cbf8ab8b-2ff4-4071-88b8-540d0cef9ba9
# ╠═6c9506d6-d81e-4905-980d-a3bbf99c0442
# ╠═e32df0fe-7fc1-4c6b-bb5f-44aaf20960f3
# ╠═4e3b4041-62a2-444d-b552-0e6e62d43cf3
# ╠═2efcacce-b8db-4dcc-8c9d-9cffa4748ca9
# ╠═309d6a20-8d69-4893-85bc-1273d7ad72a4
# ╠═72f7cdec-5a1c-451f-a9c5-ce35204237af
# ╠═4d5c9279-e0c3-4b24-9415-c8884e25a9e1
# ╠═f4f89dd8-0588-4694-8bb8-27fe619dd5f6
# ╠═790debfb-9516-429b-94b6-c007a58b0d88
# ╠═3d3bc919-8987-47ee-8270-d77d249a9926
# ╠═663acfb7-ae5a-4a73-8808-322bdc8d29ca
# ╠═929930ba-fb2c-4dbd-9d83-2dcb4cbfc8b5
# ╠═0ec9de7f-b638-4328-bd97-a3fa640b6306
# ╠═e3f50faf-3958-4c4b-9513-52fdf480efb5
# ╠═f84a8b42-7b14-43ce-bcd3-2e14ab8d2dd9
# ╠═e55be7da-3e4d-4be1-853c-fea592252656
# ╠═a4457433-ecd2-434b-9ded-602a9c84c8a2
# ╠═b6fb22d3-a1c4-468b-b5d6-28a9a9080816
# ╠═31adb6a1-f0fe-49d6-8354-41867501d5cb
# ╠═7b35c53b-932c-44c7-8997-1a04a406e6b6
# ╠═e11ac344-8c98-4c8a-bfd1-febc9f23ea31
# ╠═77d13717-42e5-41de-ba42-aca96e9256bc
# ╠═f8961d47-b607-4cf2-9306-d15ebd904227
# ╠═370a30e5-4ccd-4dd3-b90c-d57a2dc23dc8
# ╠═7c7638de-d71e-4d11-957f-165b01915e48
# ╠═076a56cc-eab4-4dd0-8429-d98acdc139cd
# ╠═c13b4535-d5ee-40d5-99cc-067b016a6634
# ╠═5d0e1bdd-9e4c-48fc-b30d-93fe106f2f7f
# ╠═ddf4d984-19e0-4e11-9484-0658e55612e0
# ╠═c7a9e6a6-e3b9-4f17-9553-04900cf6c8d4
# ╠═b1e8ae96-c484-4fb4-8517-3ceb4955b107
# ╠═4bd7a153-2a62-4250-bbf6-2a91e4228458
# ╠═68022e23-64ef-412c-b3bd-abdb70c0da3c
# ╠═df5037f8-070d-4e65-a59f-6070a8e0427e
# ╠═64710502-ebf6-4081-9cc7-91b4eeced20a
# ╠═7fa93a21-2b08-4a9a-86b3-da2f4e660b27
# ╠═086c1a13-c125-4a9a-bf32-4721e3da05f7
# ╠═37061040-69ae-44aa-9e9d-3c8ff8c8b478
# ╠═980d1c7b-2a18-41c4-aba3-b8fde3d8eb43
# ╠═78cfe580-0005-445e-b5f1-866dbedc4e9e
# ╠═1427e80a-8d7a-41ec-800e-602af22c3e38
# ╠═908f2a04-60ad-48a0-81d9-4666877e8302
# ╠═7e322413-2ce4-4c63-a585-2371947d70a2
# ╠═3ced9c4b-ead8-4f6c-a8a5-c36edf863508
# ╠═71c48042-3df6-45f1-a133-fed42448f805
# ╠═75cf6914-2a55-437f-b1f6-ace0a1ac1c28
# ╠═498bec6f-7035-4e59-995a-92c62bdbe4c7
# ╠═948b812e-438f-4b7a-9978-a445245271c9
# ╠═6ff5c526-5526-4642-a886-7b86dce0eb98
# ╠═2f6773bd-4a7a-433e-9264-ce8775025ea4
# ╠═5f82ca74-c155-4927-ab13-a3c909aeb5e4
# ╠═a1d8425d-1756-4bd0-86bc-092996f34ada
# ╠═b97e8c3c-dd05-40be-a1ab-ea59e3047c97
# ╠═bd5fc46f-2b54-4aa0-8fcc-336c4011594f
# ╠═f254852e-7edb-4fb4-8fa8-ab0409476282
# ╠═fbbbf550-7f80-4dd9-8afc-e615d78655ab
# ╠═e3b62586-b24c-4289-bf50-4e11113d367a
# ╠═a98720b6-c002-42d9-940f-4d80cc324208
# ╠═a69791d9-8e94-4c1d-944d-dea62960abbd
# ╠═47ee8744-70dd-4783-be00-8768349c6b90
# ╠═f4b52e3f-d15f-4b26-a2fe-2b590286b9f9
# ╠═327b2c85-6b92-42e5-aace-8ae9a004a967
# ╠═8fcd6911-c296-4d49-9af3-8a51d6c9ae6c
# ╠═f1c9dc95-6d75-48ca-981d-61d9ce966a5d
# ╠═a4b785e0-3ce4-433f-a976-7bff116b3ecc
# ╠═b090865b-a580-4ccc-9737-8fa35c09bd4c
# ╠═6f7aa5ce-f974-4af6-b8e3-37e3f90201ee
# ╠═6843a0e3-5c74-43cf-8b30-3f6b533b0177
# ╠═10338d9e-bb9b-4971-97df-807fd8875e49
# ╠═40096ec8-b9ec-4dae-8107-3f6f6ca0552b
# ╠═c3cba41f-3bd4-433c-8f14-5b0e1b34f3e2
# ╠═f1935958-d269-4b66-bed5-6e3f71629fc3
# ╠═58e2f746-350c-480e-8079-45179b0e5a64
# ╠═29b533f5-32ca-4d7c-9469-83c4add9d3d6
# ╠═fb7fb3f4-3eae-446e-9a56-3b75077df73f
# ╠═d9543aa8-afc9-4d97-83f9-30c25b773848
# ╠═6dbe5647-bd75-48c2-b6e8-3de5634b2b5e
# ╠═8e7add5c-cbd0-481a-b059-18653aa5ef5a
# ╠═e38d2f6e-9922-4c53-80df-1788a1f45f5d
# ╠═bd32f7a6-6fc9-4a04-9b6e-147308c714da
# ╠═9e23601c-c78a-4fdd-8cb6-575bdf86ff85
# ╠═8b4f8cc8-f3bf-4531-ae7f-275b51b65988
# ╠═2cf7067f-8307-423c-9d21-1e3fb3ca59c1
# ╠═1c6f7c98-cde4-432d-b97c-cf8167072018
