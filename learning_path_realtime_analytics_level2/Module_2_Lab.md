# Querying Data with ClickHouse

## CTEs

ClickHouse supports standard SQL CTEs, as well as CTEs with a single expression.

```
WITH 
     splitByChar(' ', ifnull(street,'')) AS street_words,
     year(date) as year
SELECT 
    year,
    street_words
FROM uk_prices_2 
LIMIT 10;
```

---

## Regular Functions Examples

### Array Functions

`arrayJoin` converts an array to multiple lines (like `explode`).

```
WITH 
    splitByChar(' ', ifnull(street,'')) AS street_words,
    year(date) as year
SELECT 
    year,
    arrayJoin(street_words) as street_word
FROM uk_prices_2 
LIMIT 10;
```

### String Manipulation

```
SELECT 
    addr1,
    countMatches(addr1, '[0-9]+'),         -- count how many times a regex exists
    extractAll(ifnull(addr1,''), '[0-9]+'), -- get regex matches
    length(addr1)
FROM uk_prices_2 
LIMIT 10;
```

### Datetime Manipulation

```
SELECT 
    now() as time_utc,
    toStartOfDay(now()),
    toStartOfMonth(now()),
    addDays(now(), 05);
```

---

## Aggregate Functions

- **sumIf**: all aggregate functions support `If` for a condition
- **argMax**: find a related value corresponding to the max of another column

```
SELECT 
    county,
    sum(price) as sales,
    sumIf(price, price > 100000) AS lux_sales,
    max(price) as top_amount,
    argMax(street, price) as top_amount_street
FROM uk_prices_3 
GROUP BY county;
```

---

## Module Lab Questions

1. **All properties that sold for more than 100,000,000 pounds, sorted by descending price**

```
SELECT *
FROM uk_prices_2 
WHERE CAST(price AS INT) > 100000000
ORDER BY CAST(price AS INT) DESC;
```

2. **How many properties were sold for over 1 million pounds in 2024?**

```
SELECT count()   -- 22471
FROM uk_prices_2 
WHERE CAST(price AS INT) > 1000000
  AND toYear(date) = 2024;
```

3. **How many unique towns are in the dataset**

```
SELECT uniq(town)  -- 1172
FROM uk_prices_2;
```

4. **Which town had the highest number of properties sold?**

```
SELECT 
    town,
    count() as sales_num
FROM uk_prices_2 
GROUP BY town
ORDER BY sales_num DESC
LIMIT 1;  -- LONDON 2287237
```

5. **Top 10 towns that are not London with the most properties sold**

```
SELECT 
    topKIf(10)(town, town <> 'LONDON')
FROM uk_prices_2;
```

6. **Top 10 most expensive towns on average**

```
SELECT 
    town,
    avg(toInt32OrNull(price)) as avg_price
FROM uk_prices_2 
GROUP BY town
ORDER BY avg_price DESC
LIMIT 10;
```

7. **Address of the most expensive property**

```
SELECT 
    addr1,
    addr2,
    street,
    town
FROM uk_prices_2 
ORDER BY toInt32OrNull(price) DESC
LIMIT 1;
```
