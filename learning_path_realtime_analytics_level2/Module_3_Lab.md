-- Inspect the file

```
    SELECT 
        date
        ,variable
        ,fixed
        ,bank
    FROM s3('https://learnclickhouse.s3.us-east-2.amazonaws.com/datasets/mortgage_rates.csv')
    LIMIT 10;
```


-- Create a dictionary

```
    CREATE DICTIONARY uk_mortgage_rates(
        date DateTime64 
        ,variable Decimal32(2)
        ,fixed Decimal32(2)
        ,bank Decimal32(2)
    )
    PRIMARY KEY (date)
    SOURCE(
        HTTP(
            url 'https://learnclickhouse.s3.us-east-2.amazonaws.com/datasets/mortgage_rates.csv'
            format 'CSVWithNames'
        )
    )
    LIFETIME(2628000000)
    LAYOUT(COMPLEX_KEY_HASHED)
    SETTINGS(date_time_input_format = 'best_effort');
```