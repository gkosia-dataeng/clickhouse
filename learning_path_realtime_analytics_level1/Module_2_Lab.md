# Understand Primary Key

## Inspect the Parts of the Table

Query the active parts for the table:

    SELECT *
    FROM system.parts
    WHERE table = 'uk_prices_1'
      AND active = 1
    SETTINGS use_query_cache = 0;

---

## Observe the Compression Ratio

Check compressed vs uncompressed data size:

    SELECT
        formatReadableSize(sum(data_compressed_bytes)) AS compressed_size,
        formatReadableSize(sum(data_uncompressed_bytes)) AS uncompressed_size
    FROM system.parts
    WHERE table = 'uk_prices_1'
      AND active = 1
    SETTINGS use_query_cache = 0;

---

## Effect of Primary Key on Querying

The primary key of the table is the `date` column.  
Filtering by a non-primary-key column forces ClickHouse to scan the entire table.

Total granules scanned:

    30033199 / 8192 ≈ 3667 granules

Example query:

    SELECT avg(toUInt32(price))
    FROM uk_prices_1
    WHERE town = 'LONDON';

---

## Filtering by Primary Key

Filtering by the primary key allows ClickHouse to skip most granules.

Granules scanned:

    106496 / 8192 ≈ 13 granules

Example query:

    SELECT avg(toUInt32(price))
    FROM uk_prices_1
    WHERE toYYYYMM(date) = '202207';

---

## Create a New Table with a Different Primary Key

Create a second table using a different primary key:

    CREATE TABLE default.uk_prices_2
    (
        id Nullable(String),
        price Nullable(String),
        date DateTime,
        postcode String,
        type Nullable(String),
        is_new Nullable(String),
        duration Nullable(String),
        addr1 Nullable(String),
        addr2 Nullable(String),
        street Nullable(String),
        locality Nullable(String),
        town Nullable(String),
        district Nullable(String),
        county Nullable(String),
        column15 Nullable(String),
        column16 Nullable(String)
    )
    ENGINE = MergeTree
    PRIMARY KEY (postcode, date);

Insert the data:

    INSERT INTO uk_prices_2
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
    FROM s3(
        'http://minIO:9000/raw-data/uk_prices.csv.zst',
        'CSVWithNames'
    );

---

## Check Compression of the New Table

Compare compression statistics for the new table:

    SELECT
        formatReadableSize(sum(data_compressed_bytes)) AS compressed_size,
        formatReadableSize(sum(data_uncompressed_bytes)) AS uncompressed_size
    FROM system.parts
    WHERE table = 'uk_prices_2'
      AND active = 1
    SETTINGS use_query_cache = 0;
