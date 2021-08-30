### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# ╔═╡ 16ba1b52-6ca5-4cdb-8657-5c0ec912bb56
using SparkSQL, DataFrames

# ╔═╡ 1a82a4df-fd0c-4c5f-b240-9672b20d017d
using GLM

# ╔═╡ 010e59a4-0933-11ec-005b-3314aac96bb8
# SparkSQL.jl machine Learning tutorial.

# ╔═╡ f44c2335-bed9-4bf2-ba4e-a30a7e26fe3e
# Example shows how to build a logistic regression machine learning model with  Julia and SparkSQL.jl. A sample advertising use case is used to provide a real world example. The example model predicts which ad campaign and media format combination produces a "click".


# ╔═╡ b2356d86-4c41-4e13-b1e6-c9fc64f9993c
SparkSQL.initJVM()

# ╔═╡ f68d5f13-89c6-4755-b8ec-c123b87c2c35
sprk = SparkSQL.SparkSession("spark://localhost:7077", "Julia & Spark Machine Learning Example")

# ╔═╡ 8f224f26-af8b-45db-b007-b542189ae20f
data = sql(sprk, "SELECT CAST(_c0 AS INTEGER) AS click, _c1 AS media, _c2 as ad_shown FROM CSV.`sampleDataML.csv`");

# ╔═╡ 196603e4-270a-45b8-afb9-4649599e78f2
# Create a temporary database view in Spark with Julia to allow queries on loaded data.

# ╔═╡ 1392d02d-0258-4183-b756-969a14dfd033
createOrReplaceTempView(data,"advertisement_data");

# ╔═╡ 35950c0c-f87a-425f-ae96-f7555dd8eaba
# Create Training data set. Get a random sample of the data for training.

# ╔═╡ 9d228706-000d-41c3-8162-9e8894eed559
trainingData = sql(sprk, "SELECT * FROM advertisement_data TABLESAMPLE(40 PERCENT)")

# ╔═╡ b22ed63c-b646-4e43-88bf-d1e5c754333a
trainingDF = toJuliaDF(trainingData)

# ╔═╡ b5ed1dd2-d1af-4d22-a6da-8b5586ccac9d
# Create test data set to validate the model. Get a random sample of the data for testing the model.

# ╔═╡ 41acbbe9-2c68-493d-b7e9-9811817a4f5a
testData = sql(sprk,"SELECT * FROM advertisement_data TABLESAMPLE(25 PERCENT)")

# ╔═╡ 4ac78ed0-ab59-4a05-b2d3-2e5143e781a9
testDF = toJuliaDF(testData)

# ╔═╡ a5c2fe1d-aa59-4048-91ad-ed00262e0f57
# The GLM (Generalized Linear Model) Julia package.

# ╔═╡ 75eafc32-fc5b-44aa-9d06-cf85c8b1d338
# Create the Logistic regression machine learning model. Ad was clicked based on the media and ad shown.

# ╔═╡ a8dfa116-2677-4df1-acc6-738b27a864bf
f = @formula(click ~ media + ad_shown)

# ╔═╡ 0254392c-61b0-4198-860f-f7450f1e04e1
model = glm(f, trainingDF, Binomial(), LogitLink());

# ╔═╡ 6b5efee9-ceb5-488c-ae8f-5adf107bf7f5
coeftable(model);

# ╔═╡ 1ec2a9c1-0033-4320-84eb-74d665bcec51
# Run the model against the test data.

# ╔═╡ 4a4fe208-f98a-4952-b0b8-f32e8a63be61
prediction = round.(predict(model, testDF), digits=3);

# ╔═╡ 15265b71-0392-411d-a9b9-77b4e72a638e
# Compare model's performance against test data.

# ╔═╡ 31a75e65-c4ab-43e0-8566-954b7274add2
insertcols!(testDF, 1, :model_predicted => [if p >= 0.5 1 else 0 end for p in prediction])

# ╔═╡ cbdc3eef-cd65-4101-bf7e-b649f632939a
# The model shows a "1" if predicting the ad was clicked and a "0" if not. 

# ╔═╡ 69ab1393-ae18-4761-a188-14f6c8464152
# Model validation is done using a confusion matrix, and ROC (Receiver Operating Characteristic) curve.

# ╔═╡ Cell order:
# ╠═010e59a4-0933-11ec-005b-3314aac96bb8
# ╠═f44c2335-bed9-4bf2-ba4e-a30a7e26fe3e
# ╠═16ba1b52-6ca5-4cdb-8657-5c0ec912bb56
# ╠═b2356d86-4c41-4e13-b1e6-c9fc64f9993c
# ╠═f68d5f13-89c6-4755-b8ec-c123b87c2c35
# ╠═8f224f26-af8b-45db-b007-b542189ae20f
# ╠═196603e4-270a-45b8-afb9-4649599e78f2
# ╠═1392d02d-0258-4183-b756-969a14dfd033
# ╠═35950c0c-f87a-425f-ae96-f7555dd8eaba
# ╠═9d228706-000d-41c3-8162-9e8894eed559
# ╠═b22ed63c-b646-4e43-88bf-d1e5c754333a
# ╠═b5ed1dd2-d1af-4d22-a6da-8b5586ccac9d
# ╠═41acbbe9-2c68-493d-b7e9-9811817a4f5a
# ╠═4ac78ed0-ab59-4a05-b2d3-2e5143e781a9
# ╠═a5c2fe1d-aa59-4048-91ad-ed00262e0f57
# ╠═1a82a4df-fd0c-4c5f-b240-9672b20d017d
# ╠═75eafc32-fc5b-44aa-9d06-cf85c8b1d338
# ╠═a8dfa116-2677-4df1-acc6-738b27a864bf
# ╠═0254392c-61b0-4198-860f-f7450f1e04e1
# ╠═6b5efee9-ceb5-488c-ae8f-5adf107bf7f5
# ╠═1ec2a9c1-0033-4320-84eb-74d665bcec51
# ╠═4a4fe208-f98a-4952-b0b8-f32e8a63be61
# ╠═15265b71-0392-411d-a9b9-77b4e72a638e
# ╠═31a75e65-c4ab-43e0-8566-954b7274add2
# ╠═cbdc3eef-cd65-4101-bf7e-b649f632939a
# ╠═69ab1393-ae18-4761-a188-14f6c8464152
