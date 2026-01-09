## Use Correct Data Types

### 1. Use the correct data types for `uk_prices` and create a new table

```
CREATE TABLE uk_prices_3
(
    id UUID,
    price UInt32,
    date DateTime,
    postcode1 String,
    postcode2 String,
    type Enum8(
        'terraced' = 1,
        'semi-detached' = 2,
        'detached' = 3,
        'flat' = 4,
        'other' = 0
    ),
    is_new UInt8,
    duration Enum8(
        'freehold' = 1,
        'leasehold' = 2,
        'unknown' = 0
    ),
    addr1 String,
    addr2 String,
    street String,
    locality LowCardinality(String),
    town LowCardinality(String),
    district LowCardinality(String),
    county LowCardinality(String)
)
ENGINE = MergeTree
PRIMARY KEY (postcode1, postcode2);

```

---

### 2. Fill the new table and compare size and performance

```
INSERT INTO uk_prices_3
WITH
    splitByChar(' ', postcode) AS postcodes
SELECT
    replaceRegexpAll(id, '[{}]', '') AS id,
    toUInt32(price) AS price,
    date,
    postcodes[1] AS postcode1,
    postcodes[2] AS postcode2,
    transform(
        type,
        ['T', 'S', 'D', 'F', 'O'],
        ['terraced', 'semi-detached', 'detached', 'flat', 'other'],
        'other'
    ) AS type,
    is_new = 'Y' AS is_new,
    transform(
        duration,
        ['F', 'L', 'U'],
        ['freehold', 'leasehold', 'unknown'],
        'unknown'
    ) AS duration,
    addr1,
    addr2,
    street,
    locality,
    town,
    district,
    county
FROM uk_prices_2;

```