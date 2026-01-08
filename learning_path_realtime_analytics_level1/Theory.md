## Module 1: Introduction to ClickHouse

### ClickHouse Use Cases

- **Real-time Analytics**  
  ClickHouse is a real-time analytical database designed for high-performance queries.  
  It is commonly used to power real-time workloads and interactive dashboards.

- **Observability**  
  ClickHouse can be used to analyze logs, events, and traces for monitoring and troubleshooting.
  
  - **ClickStack**: Uses an OpenTelemetry (OTEL) Collector as a gateway for systems to send logs and telemetry data to ClickHouse.
  - **HyperDX**: Built on top of ClickHouse to visualize and explore observability data.

- **Data Warehouse**  
  ClickHouse acts as an OLAP database optimized for analytical workloads and large-scale data exploration.

- **AI and Machine Learning**  
  ClickHouse can be used in AI and ML workflows, including:
  - MCP servers
  - Integration with LLM-based models

---

### Running ClickHouse

- **ClickHouse Cloud**  
  A fully managed ClickHouse service.

- **Self-Managed Deployment**  
  Run ClickHouse on your own infrastructure:
  - Using Docker
  - By downloading and running the ClickHouse binaries locally
    - Start the ClickHouse server application



## Module 2: ClickHouse Architecture

### Engines
- All tables must have an **Engine**
- **MergeTree**: native ClickHouse storage engine (data stored in ClickHouse)
- **S3, DeltaLake, Iceberg**: external storage engines  
  - Used for ad-hoc queries  
  - Data lives outside ClickHouse  
  - Engines act like connectors

---

## MergeTree Engine

### Primary Key
- Every MergeTree table must have a **PRIMARY KEY**
- PRIMARY KEY **does not enforce uniqueness**
- Used only for **data sorting**
- Can be defined using:
  - `PRIMARY KEY`
  - or `ORDER BY`
- PRIMARY KEY columns are stored **in memory**
- Used for:
  - Searching data
  - Inserting data
  - **Data skipping** (very important for filtering)

---

### ORDER BY
- If no PRIMARY KEY is specified, `ORDER BY` becomes the key
- If both are defined:
  - PRIMARY KEY columns must be the **prefix** of ORDER BY
- PRIMARY KEY columns:
  - Stored in memory
- Extra ORDER BY columns:
  - Not stored in memory
  - Used only to extend on-disk sorting
- Adding columns to ORDER BY (but not PRIMARY KEY):
  - Can help with **JOIN performance**
  - Improves **data compression**

---

### Granule
- A **granule** is the smallest unit ClickHouse reads from disk
- Default size:
  - 1 granule = **8192 rows**
  - Controlled by `index_granularity = 8192`
- Granules are created **after sorting**
- Each granule is assigned to **one thread**
- ClickHouse uses **all available CPU cores** to process granules

---

### Primary Index
- Each table can have **only one primary index**
- Stored **in memory**
- Contains:
  - One record per granule
  - PRIMARY KEY values of the **first row** in each granule
- Used for:
  - Sorting incoming data
  - Data skipping when filtering on primary key columns

---

### Parts
- On insert, ClickHouse writes data quickly into a new **Part**
- Each Part:
  - Is **immutable**
- Background merges:
  - Small parts are merged into larger parts automatically
  - Continues until reaching  
    `max_bytes_to_merge_at_max_space_in_pool`  
    (default: ~150 GB compressed)
- Parts metadata can be viewed in `system.parts`
- Part name format:
  - `<partition>_<initial_part>_<latest_part>_<merge_level>`

---

### Small Inserts
- `async_insert`
  - Buffers multiple small inserts
  - Executes them together at intervals
  - Helps avoid performance issues caused by small inserts

---

### Part Folder
- Each Part is an **immutable directory**
- Contains:
  - One file per column
  - One file for the PRIMARY INDEX
- PRIMARY INDEX file:
  - Acts like a dictionary of primary key values per granule  
    Example:
    - Rows 1–10 → (A,1)
    - Rows 11–19 → (A,2)

---

### MergeTree Engine Variants
- **MergeTree**: default engine
- **AggregatingMergeTree**: pre-aggregated data
- **ReplacingMergeTree**: supports upserts
- **SharedMergeTree**: ClickHouse Cloud (data in object storage)
- **ReplicatedMergeTree**: on-prem replication
