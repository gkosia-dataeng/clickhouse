## Getting Started with ClickHouse and MinIO

### 1. Start the Local Environment
Start the local data warehouse environment:

    make dwh-up

---

### 2. Open the ClickHouse Web UI
Open your browser and navigate to:

    http://localhost:8123/play

---

### 3. Login
Use the credentials defined in:

    ../local_env/README.md

---

### 4. Inspect Existing Databases
List all available databases:

    SHOW DATABASES;

---

### 5. Read Data from MinIO Using the `s3` Function

Use the `s3` table function to read files stored in MinIO.

**CSVWithNames** indicates that the first row of the file contains column headers.

Query the file:

    SELECT *
    FROM s3('http://minIO:9000/raw-data/uk_prices.csv.zst', 'CSVWithNames');

Inspect the file structure (columns and types):

    DESC s3('http://minIO:9000/raw-data/uk_prices.csv.zst', 'CSVWithNames');

---

### 6. Create an In-Memory Table
Create a temporary table backed by the `Memory` engine for quick inspection:

    CREATE OR REPLACE TABLE uk_prices_temp
    ENGINE = Memory
    AS
        SELECT *
        FROM s3('http://minIO:9000/raw-data/uk_prices.csv.zst', 'CSVWithNames')
        LIMIT 100;

---

### 7. Inspect the Table Definition
Review how the table was created:

    SHOW CREATE TABLE uk_prices_temp;

---

### 8. Create a MergeTree Table
Create a persistent table using the `MergeTree` engine:

    CREATE TABLE default.uk_prices_1
    (
        `id` Nullable(String),
        `price` Nullable(String),
        `date` DateTime,
        `postcode` Nullable(String),
        `type` Nullable(String),
        `is_new` Nullable(String),
        `duration` Nullable(String),
        `addr1` Nullable(String),
        `addr2` Nullable(String),
        `street` Nullable(String),
        `locality` Nullable(String),
        `town` Nullable(String),
        `district` Nullable(String),
        `county` Nullable(String),
        `column15` Nullable(String),
        `column16` Nullable(String)
    )
    ENGINE = MergeTree
    PRIMARY KEY date
    ORDER BY date
    SETTINGS index_granularity = 8192

---

### 9. Ingest Data into the MergeTree Table
The source file stores datetime values in the format `yyyy-mm-dd hh:mm` (seconds are missing).  
Use `parseDateTimeBestEffort` to normalize the datetime during ingestion:

    INSERT INTO uk_prices_1
    SELECT
        id,
        price,
        parseDateTimeBestEffort(date),
        postcode,
        type,
        is_new,
        duration,
        addr1,
        addr2,
        street,
        locality,
        town,
        district,
        county,
        column15,
        column16
    FROM s3('http://minIO:9000/raw-data/uk_prices.csv.zst', 'CSVWithNames');
