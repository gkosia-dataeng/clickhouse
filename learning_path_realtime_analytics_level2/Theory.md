## Modeling Data

### Data Types

- **Unsigned / Signed Integers**
  - `UInt[8,16,32,64,128,256]`
  - `Int[8,16,32,64,128,256]`

- **Floating Point**
  - `Float[16,32,64]`

- **Decimal**
  - `Decimal(P, S)`

- **String Types**
  - `String`
  - `FixedString(N)`

- **Date & Time**
  - `Date`
  - `Time`
  - `DateTime` → seconds precision
  - `DateTime64` → milliseconds, microseconds, nanoseconds

- **Other Types**
  - `Enum`
  - `Array`
  - `Tuple`

---

### Nullable Columns

- Nullable columns **cannot** be part of the primary key.

**How ClickHouse manages Nullable columns:**
- For each Nullable column, ClickHouse:
  - Stores a default value (e.g., `0`) in the original column
  - Creates an additional hidden column with values `0` or `1` to indicate `NULL`
- When queried, ClickHouse merges these two columns to produce the final result

**Best Practices:**
- Avoid Nullable columns due to extra storage and processing cost
- Prefer defining meaningful `DEFAULT` values or filtering invalid data later

    Example:
    - `Price Int16 DEFAULT 0`

---

### JSON

- Stores any JSON schema in a single column
- During parsing:
  - If an element does not exist, the result will be `NULL`

---

### LowCardinality

- Intended for `String` columns with a relatively small number of unique values
- ClickHouse:
  - Creates a dictionary to encode unique strings
  - Stores column values as integers

    Example:
    - `1 => 'aaaa'`
    - `2 => 'asdsd'`

---

### Default Column Values

- **DEFAULT**
  - If the value is `NULL`, the default value is applied

    Example:
    - `Price Int16 DEFAULT 0`

- **EPHEMERAL**
  - Placeholder to match incoming schema
  - Column is not stored and not returned in `SELECT`

    Example:
    - `message String EPHEMERAL`

- **MATERIALIZED**
  - Calculated column
  - Not returned by `SELECT *`
  - Must be explicitly selected in queries

    Example:
    - `total Float64 MATERIALIZED price * quantity`

---

### Partitioning

- Partitions consist of multiple **parts**
- Each `INSERT` statement creates a new part
- If partitioning is defined:
  - Each insert may create separate parts per partition value
- Use columns with **low cardinality** for partitioning
- During merges:
  - Smaller parts are merged into larger parts within the same partition

**Best Practice:**
- Partition by month (most cases do not require partitioning)

    Example:
    - `ENGINE = MergeTree`
    - `PARTITION BY toYYYYMM(timestamp)`

**Important Settings:**
- `max_partitions_per_insert_block`
  - If an insert creates more partitions than this limit, the insert will fail

***Note:***
- Partitions are primarily for **data management**, not query performance
- Common operations:
  - `DETACH PARTITION`
  - `DROP PARTITION`
  - `MOVE PARTITION`
  - `REPLACE PARTITION`


### Query Data in ClickHouse

ClickHouse supports **CTEs** with standard SQL syntax, as well as CTEs with a single statement.

```
WITH 
    now() AS curr_time
SELECT *
FROM LOGS
WHERE log_time > curr_time - 10
```

---

#### Regular Functions

- **arrayJoin**: converts an array to multiple rows (similar to `explode` in Spark).

---

#### Aggregated Functions

- All aggregate functions support `If` for a condition:
  ```sql
  countIf(user, isactive = 1)
  ```

- Relate an aggregation with a selection:
```
SELECT 
    town,
    max(price) AS price,
    argMax(street, price)  -- get the street of the town that has the max(price)
FROM uk_price_paid
GROUP BY town;
```

---

#### User-Defined Functions (UDFs)

You can create custom functions:

```
CREATE FUNCTION dosomething(p1, p2) -> concat(p1, p2);
```


## Joining Data

The right table in the join is cached to memory, so in the JOIN put the smallest table to the right.

### Join Algorithms

#### Direct Join
**RIGHT TABLE IS PRELOADED TO MEMORY**

Three options for implementing Direct Join:

1. **Dictionary**
   - A special key-value table stored in-memory.
   - Create the tables as Dictionaries: `CREATE DICTIONARY dicti_example ...`
   - Dictionary tables are stored in-memory on every node (replicated).
   - On `CREATE DICTIONARY`, you can specify how often the dictionary will be updated.
   - Dictionaries have special functions to work with them.

2. **Join Table Engine**
   - Right table is created and preloaded using `ENGINE = JOIN`.
   - Stored in-memory.

3. **EmbeddedRocksDB**
   - Right table is a RocksDB table.

#### Hash Join
- ***Memory bound***, creates a hash table of the right table and matches the rows.

#### Parallel Hash Join
- ***Memory bound***, same as hash but splits the right table into multiple hash tables.

#### Grace Hash Join
- Similar to hash but **not memory bounded**.

#### Full Sorting Merge Join
- Sort-merge join, used when both tables are sorted by the join column (Primary keys).

#### Partial Merge Join
- Variant of full sorting merge but minimizes memory.
- Used when the right table is already sorted by the join column (its primary key).

### Specifying the Join Algorithm
`SETTINGS join_algorithm = 'grace_hash';`

### Guidelines for Choosing Join Algorithm
- Right table can be preloaded and stay in memory → **Direct Join**  
- Both tables are sorted by join columns → **Full Sort Merge**  
- Right table fits in memory → **Parallel Hash** or **Hash**  
- Otherwise → **Full Sort Merge**, **Grace Hash**, or **Partial Merge**
