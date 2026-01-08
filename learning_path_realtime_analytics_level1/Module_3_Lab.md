## Inspect the Schema of a Parquet File

Inspect the schema of the `noaa_enriched.parquet` file directly from S3:

    DESC s3('http://minIO:9000/raw-data/noaa_enriched.parquet')
    SETTINGS schema_inference_make_columns_nullable = 0;

---

## Create a Temporary Table to Infer the Schema

Create an in-memory table to materialize the schema:

    CREATE TABLE weather_temp
    ENGINE = Memory
    AS
    SELECT *
    FROM s3('https://datasets-documentation.s3.eu-west-3.amazonaws.com/noaa/noaa_enriched.parquet')
    LIMIT 100
    SETTINGS schema_inference_make_columns_nullable = 0;

---

## Get the Schema of the Temporary Table

Inspect the table definition:

    SHOW CREATE TABLE weather_temp;

---

## Create the MergeTree Table

Create the final MergeTree table using the inferred schema:

    CREATE TABLE default.weather
    (
        station_id LowCardinality(String),
        date Date32,
        tempAvg Int32,
        tempMax Int32,
        tempMin Int32,
        precipitation Int32,
        snowfall Int32,
        snowDepth Int32,
        percentDailySun Int8,
        averageWindSpeed Int32,
        maxWindSpeed Int32,
        weatherType UInt8,
        location Tuple(
            1 Float64,
            2 Float64
        ),
        elevation Float32,
        name LowCardinality(String)
    )
    ENGINE = MergeTree
    PRIMARY KEY date;

---

## Ingest Records After 1995

Insert only records newer than 1995:

    INSERT INTO default.weather
    SELECT *
    FROM s3('https://datasets-documentation.s3.eu-west-3.amazonaws.com/noaa/noaa_enriched.parquet')
    WHERE date > '1995-01-01';

---

## Query the Data

Query extreme temperature values:

    SELECT
        tempMax / 10 AS maxTemp,
        location,
        name,
        date
    FROM weather
    WHERE tempMax > 500
    ORDER BY
        tempMax DESC,
        date ASC
    LIMIT 10;

---

## Insert an Imperfect CSV File

### Detect the Delimiter

Inspect the CSV schema and delimiter:

    DESC s3('http://minio:9000/raw-data/operating_budget.csv')
    SETTINGS format_csv_delimiter = '~';

---

### Handle NULL Numeric Values

Convert NULLs to zero when aggregating:

    SELECT sum(toUInt32OrZero(approved_amount))
    FROM s3('http://minio:9000/raw-data/operating_budget.csv')
    SETTINGS format_csv_delimiter = '~';
