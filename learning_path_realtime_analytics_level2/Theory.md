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
