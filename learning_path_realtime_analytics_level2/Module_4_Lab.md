## Create a Simple Table with MergeTree

Create a simple table using the `MergeTree` engine:

    CREATE TABLE myUpsertTable (
        custId Int16,
        Balance Float64
    )
    ENGINE = MergeTree
    ORDER BY custId;

---

## Insert Two Records

    INSERT INTO myUpsertTable VALUES (1, 10);
    INSERT INTO myUpsertTable VALUES (2, 20);

---

## Inspect the Parts of the Table

    SELECT *
    FROM system.parts
    WHERE table = 'myUpsertTable'
      AND active = 1
    SETTINGS use_query_cache = 0;

---

## Delete a Record

    ALTER TABLE myUpsertTable
    DELETE WHERE custId = 1;

---

## Check the Mutations

`is_done = 1` means the record has been deleted.

    SELECT is_done, *
    FROM system.mutations
    WHERE table = 'myUpsertTable'
    SETTINGS use_query_cache = 0;

---

## Check the Parts Again

The part has been merged.

    SELECT *
    FROM system.parts
    WHERE table = 'myUpsertTable'
      AND active = 1
    SETTINGS use_query_cache = 0;

---

## Create the Same Table with ReplacingMergeTree

    CREATE TABLE myUpsertTable (
        custId Int16,
        Balance Float64
    )
    ENGINE = ReplacingMergeTree
    ORDER BY custId;

---

## Insert Some Records

    INSERT INTO myUpsertTable VALUES (1, 10);
    INSERT INTO myUpsertTable VALUES (2, 20);

---

## Update Balance for Customer 1

Insert a new record with the same key:

    INSERT INTO myUpsertTable VALUES (1, 55);

---

## Check the Data (With and Without FINAL)

    SELECT *
    FROM myUpsertTable;

    SELECT *
    FROM myUpsertTable
    FINAL;

---

## Optimize and Check Again

    OPTIMIZE TABLE myUpsertTable;

    SELECT *
    FROM myUpsertTable;
