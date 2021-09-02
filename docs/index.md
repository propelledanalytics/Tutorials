# SparkSQL.jl Blog

Welcome to the official SparkSQL.jl Blog. This blog teaches Julia developers best practices for using the SparkSQL.jl package. 


## Posts:

1. [Top 3 benefits of using the SparkSQL.jl Julia package](#top-3-benefits-of-using-the-sparksqljl-julia-package)

2. [Project links](#project-links)

3. [SparkSQL.jl and tutorials environment setup](#sparksqljl-and-tutorials-environment-setup)

4. [SparkSQL.jl release 1.1.0 announcement](#sparksqljl-release-110-announcement)

5. [SparkSQL.jl release 1.0.0 announcement](#sparksqljl-release-100-announcement)

6. [Introduction to SparkSQL.jl tutorial](#introduction-to-sparksqljl-tutorial)

7. [Working with data tutorial](#working-with-data-tutorial)

8. [Machine learning with SparkSQL.jl tutorial](#machine-learning-with-sparksqljl-tutorial)

## Top 3 benefits of using the SparkSQL.jl Julia package
SparkSQL.jl enables Julia programs to work with Apache Spark data using just SQL.  Here are the top 3 reasons to use Julia with Spark for data science:

1. Julia is a modern programming language that has state-of-the art data science packages and is much faster than Python.                           

2. Apache Spark is one of the world's most ubiquitous open-source big data processing platforms. SparkSQL.jl allows Julia programmers to create Spark applications in Julia.

3. Used together, Julia with Apache Spark forms the most advanced data science platform. SparkSQL.jl makes it happen.


## Project links

The official SparkSQL.jl project page is located here:
- [https://github.com/propelledanalytics/SparkSQL.jl](https://github.com/propelledanalytics/SparkSQL.jl)

The official tutorial page for SparkSQL.jl is here:
- [https://github.com/propelledanalytics/Tutorials](https://github.com/propelledanalytics/Tutorials)


## SparkSQL.jl and tutorials environment setup

The "Tutorials_SparkSQL" folder has the Julia Pluto notebook tutorials and sample data. To run the Pluto notebook tutorials, setup Apache Spark and your Julia environment:

1. Install Apache Spark 3.1.2 or later: [http://spark.apache.org/downloads.html](http://spark.apache.org/downloads.html)
2. Install either OpenJDK 8 or 11: 
   - [https://developer.ibm.com/languages/java/semeru-runtimes/downloads](https://developer.ibm.com/languages/java/semeru-runtimes/downloads) (OpenJ9)
   - [https://adoptium.net](https://adoptium.net)
3. Setup your JAVA_HOME and SPARK_HOME enviroment variables: 
   - `export JAVA_HOME=/path/to/java` 
   - `export SPARK_HOME=/path/to/Apache/Spark`
4. Start Apache Spark (note using default values):
   - /path/to/Apache/Spark/sbin/start-master.sh
   - /path/to/Apache/Spark/sbin/start-worker.sh --master localhost:7070
5. Ensure your JAVA_HOME and SPARK_HOME are set and then start Julia:
   - `JULIA_COPY_STACKS=yes julia`
6. Install SparkSQL.jl along with other required Julia Packages:
   - `] add SparkSQL; add DataFrames; add Decimals; add Dates; add Pluto;`
7. Launch the Pluto notebook:
   - `Using Pluto; Pluto.run();`
8. Download the tutorial Notebooks and sample data from the [Tutorials_SparkSQL](https://github.com/propelledanalytics/Tutorials/tree/main/Tutorials_SparkSQL) repository. In Pluto, navigate to where you saved the tutorial notebooks.
9. The notebooks will run automatically. 


## SparkSQL.jl release 1.1.0 announcement

This post is announcing the release of SparkSQL.jl version 1.1.0.

SparkSQL.jl is software that enables Julia programs to work with Apache Spark using just SQL.

Apache Spark is one of the world’s most ubiquitous open-source big data processing engines. Spark’s distributed processing power enables it to process very large datasets. Apache Spark runs on many platforms and hardware architectures including those used by large enterprise and government.

Released in 2012, Julia is a modern programming language ideally suited for data science and machine learning workloads. Expertly designed, Julia is a highly performant language. It sports multiple-dispatch, auto-differentiation and a rich ecosystem of packages.

SparkSQL.jl provides the functionality that enables using Apache Spark and Julia together for tabular data. With SparkSQL.jl, Julia takes the place of Python for data science and machine learning work on Spark.

New features of this release are:

- DataFrames 1.2.2 support
- A new progress meter that shows time elapsed and row count metrics. The progress meter provides visibility to processing status when moving larger datasets between Julia and Spark. 

Install SparkSQL.jl via the Julia REPL:

```
] add SparkSQL
```
Update from earlier releases of SparkSQL.jl via the Julia REPL:
```
] update SparkSQL
update DataFrames
```

Example usage:
```
JuliaDataFrame = DataFrame(tickers = ["CRM", "IBM"])
onSpark = toSparkDS(sprk, JuliaDataFrame)
createOrReplaceTempView(onSpark, "julia_data")
query = sql(sprk, "SELECT * FROM spark_data WHERE TICKER IN (SELECT * FROM julia_data)")
results = toJuliaDF(query)
describe(results)
```
Official Project Page:
- [https://github.com/propelledanalytics/SparkSQL.jl](https://github.com/propelledanalytics/SparkSQL.jl)


## SparkSQL.jl release 1.0.0 announcement

This post is announcing the availability of the SparkSQL.jl package.

SparkSQL.jl is an open-source software package that enables the Julia programming language to work with Apache Spark using just SQL and Julia.

Apache Spark is one of the world’s most ubiquitous open-source big data processing engines. Spark’s distributed processing power enables it to process very large datasets. Apache Spark runs on many platforms and hardware architectures including those used by large enterprise and government. By utilizing SparkSQL.jl, Julia can program Spark clusters running on:

- Enterprise: IBM POWER, z/Architecture (mainframe), x86, ARM, and SPARC
- HPC: POWER 9 with NVLINK and CAPI
- Cloud: Azure, AWS, Google GCP, IBM Cloud, and Oracle Cloud (OCI).

Released in 2012, Julia is a modern programming language ideally suited for data science and machine learning workloads. Expertly designed, Julia is a highly performant language. It sports multiple-dispatch, auto-differentiation and a rich ecosystem of packages.

SparkSQL.jl provides the functionality that enables using Apache Spark and Julia together for tabular data. With SparkSQL.jl, Julia takes the place of Python for data science and machine learning work on Spark. Apache Spark data science tooling that is free from the limitations of Python represents a substantial upgrade.

For decision makers, SparkSQL.jl is the safe choice in data science tooling modernization. Julia interoperates with Python. That means legacy code investments are protected while gaining new capabilities.

The SparkSQL.jl package is designed to support many advanced features including Delta Lake. Delta Lake architecture is a best practice for multi-petabyte and trillion+ row datasets. The focus on tabular data using SQL means the Spark RDD API is not supported.

You can install SparkSQL.jl via the Julia REPL:

```
] add SparkSQL
```
Example usage:

```
JuliaDataFrame = DataFrame(tickers = ["CRM", "IBM"])
onSpark = toSparkDS(sprk, JuliaDataFrame)
createOrReplaceTempView(onSpark, "julia_data")
query = sql(sprk, "SELECT * FROM spark_data WHERE TICKER IN (SELECT * FROM julia_data)")
results = toJuliaDF(query)
describe(results)
```
Official Project Page:
- [https://github.com/propelledanalytics/SparkSQL.jl](https://github.com/propelledanalytics/SparkSQL.jl)


## Introduction to SparkSQL.jl tutorial

The introduction to SparkSQL tutorial covers:
- How to submit a Julia application to Apache Spark using Julia.
- Load a CSV files in Spark using Julia
- Create database views in Spark using Julia
- Query Spark data using Julia
- Move Spark data into a Julia DataFrame
- Chart Spark data in Julia with StatsPlots
- Move Julia DataFrame data into Apache Spark 

Download the tutorial:
[Tutorial_00_SparkSQL_Notebook.jl](https://github.com/propelledanalytics/Tutorials/tree/main/Tutorials_SparkSQL/Tutorial_00_SparkSQL_Notebook.jl)


### Notebook output:
<img src="img/00.png" width="720" height="1105" />
<img src="img/01.png" width="720" height="1138" />
<img src="img/02.png" width="720" height="462" />
<img src="img/03.png" width="720" height="1402" />
<img src="img/04.png" width="720" height="245" />

## Working with data tutorial

The working with data tutorial covers:
- Working with CSV files
- Casting (converting) data types from Text (String) to Dates and Numbers
- Writing files to disk in Parquet format
- Querying data in Spark using Julia
- Moving data from Spark to Julia DataFrames
- Creating Julia DataFrames and moving DataFrames to Apache Spark
- Using Spark and Julia DataFrame data together in SQL queries

Download the tutorial:
[Tutorial_01_Data_Notebook.jl](https://github.com/propelledanalytics/Tutorials/tree/main/Tutorials_SparkSQL/Tutorial_01_Data_Notebook.jl)

### Notebook output:
<img src="img/05.png" width="720" height="821" />
<img src="img/06.png" width="720" height="688" />
<img src="img/07.png" width="720" height="679" />
<img src="img/08.png" width="720" height="710" />

## Machine learning with SparkSQL.jl tutorial

The machine learning with SparkSQL tutorial covers:
- Using SparkSQL.jl to create training and test datasets
- Building a logistic regression machine learning model 
- Training and evaluating the model
- Using the model to make predictions


Download the tutorial:
[Tutorial_02_MachineLearning_Notebook.jl](https://github.com/propelledanalytics/Tutorials/tree/main/Tutorials_SparkSQL/Tutorial_02_MachineLearning_Notebook.jl)

### Notebook output:
<img src="img/09.png" width="720" height="1149" />
<img src="img/10.png" width="720" height="898" />
<img src="img/11.png" width="720" height="602" />
