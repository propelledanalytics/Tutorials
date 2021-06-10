# SparkSQL.jl Blog

Welcome to the official SparkSQL.jl Blog. This blog teaches Julia developers best practices for using the SparkSQL.jl package. 


## Posts:

1. [Top 3 benefits of using the SparkSQL.jl Julia package](#top-3-benefits-of-using-the-sparksqljl-julia-package)

2. [Project links](#project-links)

3. [SparkSQL.jl and tutorials environment setup](#sparksqljl-and-tutorials-environment-setup)

4. [Introduction to SparkSQL.jl tutorial](#introduction-to-sparksqljl-tutorial)

5. [Working with data tutorial](#working-with-data-tutorial)


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

1. Install Apache Spark 3.1.1 or later: [http://spark.apache.org/downloads.html](https://adoptopenjdk.net/)
2. Install either OpenJDK 8 or 11: [https://adoptopenjdk.net/](https://adoptopenjdk.net/)
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
