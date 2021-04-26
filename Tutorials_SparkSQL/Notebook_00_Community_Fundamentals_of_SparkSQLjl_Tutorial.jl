### A Pluto.jl notebook ###
# v0.14.3

using Markdown
using InteractiveUtils

# ╔═╡ e3725bf4-a3dc-11eb-2ebb-bf94a858f39a
using SparkSQL, DataFrames, Decimals, Dates

# ╔═╡ cccca8da-6ee8-4ce1-9f46-fd13dd6c209b
using StatsPlots

# ╔═╡ c031a91e-ef69-4b98-9b7a-66347f65f908
# Stock Analysis Example with Julia & Spark using the SparkSQL.jl package.

# ╔═╡ b0c17e9b-21b9-44cc-924c-35f656a10793
# SparkSQL and DataFrames packages are required; Decimals, and Dates are needed if those types are present in your data.

# ╔═╡ 863e724b-44a8-4dc6-b91f-4b596a167568
# Use initJVM to initialize the Java Virtual Machine. 

# ╔═╡ b2203415-7169-41dc-8f80-bc843f5ed06c
SparkSQL.initJVM()

# ╔═╡ 337c4b04-6ae5-495a-aa47-22bc7bdb66b4
# SparkSession is the entry point to using the Apache Spark Dataset & Dataframe API. Pass the the url for Spark, and your app name as arguments.  (Additional arguments are supported, see SparkSQL.jl package help for more details)

# ╔═╡ 58199e82-0651-414c-863d-06cee4ce61ca
sprk = SparkSQL.SparkSession("spark://localhost:7077", "Julia Spark Stock App");

# ╔═╡ 689913c0-af7e-4616-aafa-560c3537d43d
# From Julia, instruct Spark to query data using a CSV file. The example file does not have column headers, so "_c0, _c1, ... _cN" is used to refer the columns positionally to alias column names.  

# ╔═╡ d5ce8110-6afa-4a31-8135-50e6d9fc938f
loadData = sql(sprk, "SELECT _c0 TICKER, _c1 DATE,_c2 OPEN,_c3 HIGH,_c4 LOW,_c4 CLOSE,_c6 VOL FROM CSV.`sampleData.csv`;");

# ╔═╡ 8d1dd0b1-f422-4ed6-b540-f164d574a559
# Create a temporary database view in Spark with Julia to provide 

# ╔═╡ 8a78b16e-316e-4639-ba72-a4fd6c326822
createOrReplaceTempView(loadData, "rawdata");

# ╔═╡ 112e6688-220e-4a88-8fa5-711c0b45f1d7
# Prep the data in Spark from Julia by casting the string values into the correct data types.  Notice we use the database view name we just created in the FROM clause.

# ╔═╡ 6b228ad4-60f8-4104-8c71-ac88d6444f27
 prepData= sql(sprk,"SELECT TICKER, to_date(DATE, 'yyyymmdd' ) AS DATE, cast(OPEN AS double) OPEN, cast(LOW as double) LOW, cast(HIGH AS double) AS HIGH, cast(CLOSE as double) as CLOSE, cast(VOL as integer) as VOL FROM rawdata")

# ╔═╡ 719cd252-573e-408c-8694-974e5a455860
#Create a database view for the prepared data, "stocks".

# ╔═╡ c489dd64-6abc-417f-a640-2fe235c8a94b
createOrReplaceTempView(prepData,"stocks")

# ╔═╡ aeb0d1df-70c9-47e0-a815-fffca74bda73
#Create an aggregate query in Spark from Julia to get the average, min and max close price for IBM stock by year.

# ╔═╡ d99f6039-6bc7-4d38-aa12-9cf0660a59ee
queryTickerIBM = sql(sprk, "SELECT YEAR(DATE) AS TRADE_YEAR, AVG(CLOSE) AVG_CLOSE, MIN(CLOSE) MIN_CLOSE, MAX(CLOSE) MAX_CLOSE FROM stocks WHERE TICKER = 'IBM' AND YEAR(DATE) > 2007 GROUP BY YEAR(DATE) ORDER BY YEAR(DATE) DESC")

# ╔═╡ 9e2a359f-18e0-43e5-aa02-0f3884e93f24
# Move the query results from Spark to a Julia DataFrame with the "toJuliaDF" function.

# ╔═╡ ddfc9503-e132-4832-869e-9db1ee79b273
ibmTicker = toJuliaDF(queryTickerIBM)

# ╔═╡ 80e4f0ea-ded8-49f4-ac0a-181e23de530c
# Create a new Spark query to get the daily trade prices after 2007.

# ╔═╡ f0886653-6f2a-4e0a-98fa-afa2b5e26417
queryIBMdailyPrice = sql(sprk, "SELECT TICKER, DATE, OPEN, HIGH, LOW, CLOSE, VOL FROM stocks WHERE TICKER = 'IBM' AND YEAR(DATE) > 2007")

# ╔═╡ e8d16d90-e0cb-49d3-a62f-34091ed7a9c0
# Move the daily stock price query data from Spark to a Julia DataFrame.

# ╔═╡ e01e724f-198b-400a-832d-38186d587dc2
ibmTickerDaily = toJuliaDF(queryIBMdailyPrice)

# ╔═╡ 76ec754a-f397-43c9-a34a-780aa0f6fa82
# The data is now in a Julia DataFrame. Let's create a chart.

# ╔═╡ 08d03e24-2e08-4d99-9d0a-c5bad13d3153
@df ibmTickerDaily density(:CLOSE, label="IBM Stock Price Distribution 2008-2020", legend=:topleft)

# ╔═╡ 97e46d43-ac63-44da-90ed-dc959a422147
# Add data to the Julia DataFrame: 

# ╔═╡ eb35660f-a0c8-4f76-9529-5a23cc627fb5
push!(ibmTickerDaily, ["IBM", Dates.Date("9999-1-30", dateformat"yyyy-mm-dd"), 100, 100, 100, 100, 1000000])

# ╔═╡ f0f0bb02-7c25-4f23-98b7-5708f16015e7
# Send the Julia DataFrame data back to Apache Spark.

# ╔═╡ e3aee473-c606-4977-b616-bdaeda545c3d
moveToSpark = toSparkDS(sprk, ibmTickerDaily)

# ╔═╡ 3ca39b89-016a-4126-a378-7b2678049eba
# The data is in Spark, create database view to use it with SQL.

# ╔═╡ 92459661-2d84-44ff-a2fa-8a9cce682716
createOrReplaceTempView(moveToSpark,"ticker_refresh")

# ╔═╡ 2e250ef2-6f53-4519-96a9-b37ed8f099e7
# Split the data back into columns and assign column names. (Note: "," is the default delimiter. To use a different delimiter, see SparkSQL.jl help for instructions.)

# ╔═╡ ae425c7d-69c5-4a2a-82d0-a98ec213d4a5
wrangleData = sql(sprk, "SELECT 
	split(value, ',' )[0] AS TICKER,
	split(value, ',' )[1] AS DATE,
	split(value, ',' )[2] AS OPEN,
    split(value, ',' )[4] AS HIGH,
	split(value, ',' )[5] AS LOW,
	split(value, ',' )[6] AS CLOSE,
	split(value, ',' )[7] AS VOL
	FROM ticker_refresh")

# ╔═╡ 8291a7f5-77f2-4d3e-86d0-4f8c23c9fe48
# Update the view to reflect the new columns and names

# ╔═╡ 1c6788d2-c2ea-419c-acfe-ea16af1d28e1
createOrReplaceTempView(wrangleData, "ticker_refresh")

# ╔═╡ 0b4b82a8-f21e-422c-b380-993138ed6c3e
#  Cast the data types. (Note: format for date is now "yyyy-mm-dd"; the CSV file was "yyyymmdd")

# ╔═╡ 27a8d2ed-8068-4088-93c2-954eef97d284
castTypes = sql(sprk, "SELECT TICKER, to_date(DATE, 'yyyy-mm-dd' ) AS DATE, cast(OPEN AS double) OPEN, cast(HIGH AS double) AS HIGH, cast(LOW as double) LOW, cast(CLOSE as double) as CLOSE, cast(VOL as integer) as VOL FROM ticker_refresh")

# ╔═╡ b8d36775-2f69-4866-80fa-a246af321c6a
# Replace the "stocks" view with the updated data from the Julia DataFrame.

# ╔═╡ c0bbb615-bef7-4153-9077-03681aae9c14
createOrReplaceTempView(castTypes, "stocks")

# ╔═╡ 50b99063-7958-4eac-995e-5a8aa4316955
# Show the row added to the Julia DataFrame is now in Spark. Query to find max date in Spark. (The expected output is "9999-1-30")

# ╔═╡ 526a5b0d-2a20-4274-8b69-6604509ca62f
getTopRecord = sql(sprk, "SELECT MAX(DATE) AS MaxDate FROM stocks")

# ╔═╡ cc5bc142-e1c2-47d5-85f4-d56fa59bde8c
# View the SparkSQL query results with the "toJuliaDF" function.

# ╔═╡ 3eaed1b0-6339-4ec9-9113-2d2ebfba2efc
maxDate = toJuliaDF(getTopRecord)

# ╔═╡ daae34e7-4ba0-4108-85c6-6fb8ce695327
# Congratulations! You now know the fundementals using the SparkSQL.jl Julia package. 

# ╔═╡ Cell order:
# ╠═c031a91e-ef69-4b98-9b7a-66347f65f908
# ╠═b0c17e9b-21b9-44cc-924c-35f656a10793
# ╠═e3725bf4-a3dc-11eb-2ebb-bf94a858f39a
# ╠═863e724b-44a8-4dc6-b91f-4b596a167568
# ╠═b2203415-7169-41dc-8f80-bc843f5ed06c
# ╠═337c4b04-6ae5-495a-aa47-22bc7bdb66b4
# ╠═58199e82-0651-414c-863d-06cee4ce61ca
# ╠═689913c0-af7e-4616-aafa-560c3537d43d
# ╠═d5ce8110-6afa-4a31-8135-50e6d9fc938f
# ╠═8d1dd0b1-f422-4ed6-b540-f164d574a559
# ╠═8a78b16e-316e-4639-ba72-a4fd6c326822
# ╠═112e6688-220e-4a88-8fa5-711c0b45f1d7
# ╠═6b228ad4-60f8-4104-8c71-ac88d6444f27
# ╠═719cd252-573e-408c-8694-974e5a455860
# ╠═c489dd64-6abc-417f-a640-2fe235c8a94b
# ╠═aeb0d1df-70c9-47e0-a815-fffca74bda73
# ╠═d99f6039-6bc7-4d38-aa12-9cf0660a59ee
# ╠═9e2a359f-18e0-43e5-aa02-0f3884e93f24
# ╠═ddfc9503-e132-4832-869e-9db1ee79b273
# ╠═80e4f0ea-ded8-49f4-ac0a-181e23de530c
# ╠═f0886653-6f2a-4e0a-98fa-afa2b5e26417
# ╠═e8d16d90-e0cb-49d3-a62f-34091ed7a9c0
# ╠═e01e724f-198b-400a-832d-38186d587dc2
# ╠═76ec754a-f397-43c9-a34a-780aa0f6fa82
# ╠═cccca8da-6ee8-4ce1-9f46-fd13dd6c209b
# ╠═08d03e24-2e08-4d99-9d0a-c5bad13d3153
# ╠═97e46d43-ac63-44da-90ed-dc959a422147
# ╠═eb35660f-a0c8-4f76-9529-5a23cc627fb5
# ╠═f0f0bb02-7c25-4f23-98b7-5708f16015e7
# ╠═e3aee473-c606-4977-b616-bdaeda545c3d
# ╠═3ca39b89-016a-4126-a378-7b2678049eba
# ╠═92459661-2d84-44ff-a2fa-8a9cce682716
# ╠═2e250ef2-6f53-4519-96a9-b37ed8f099e7
# ╠═ae425c7d-69c5-4a2a-82d0-a98ec213d4a5
# ╠═8291a7f5-77f2-4d3e-86d0-4f8c23c9fe48
# ╠═1c6788d2-c2ea-419c-acfe-ea16af1d28e1
# ╠═0b4b82a8-f21e-422c-b380-993138ed6c3e
# ╠═27a8d2ed-8068-4088-93c2-954eef97d284
# ╠═b8d36775-2f69-4866-80fa-a246af321c6a
# ╠═c0bbb615-bef7-4153-9077-03681aae9c14
# ╠═50b99063-7958-4eac-995e-5a8aa4316955
# ╠═526a5b0d-2a20-4274-8b69-6604509ca62f
# ╠═cc5bc142-e1c2-47d5-85f4-d56fa59bde8c
# ╠═3eaed1b0-6339-4ec9-9113-2d2ebfba2efc
# ╠═daae34e7-4ba0-4108-85c6-6fb8ce695327
