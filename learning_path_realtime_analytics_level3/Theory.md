## Query acceleration

    Materialized views:

        Refreshable materialized view: has a target table and periodically get refreshed and store the data in the target table
                                       it calculate the data of the query in another table and when its ready it swap the table names
            1. Create the target table
            2. Create the materialized view
                    CREATE MATERIALIZED VIEW <>
                    REFRESH EVERY <Interval>
                    TO <target_table>
                    as
                    <query>

            Materialized view will be refreshed every NInterval
            Can be refreshed manual: SYSTEM REFRESH VIEW <view_name>
            Change interval:         ALTER TABLE <view_name> MODIFY REFRESH EVERY <interval>

            system.view_refreshes: monitor refresh

        Incremental materialized views: The target table updated realtime
                                        The query executed only on new rows inserted
                                        The query of materialized view is triggered only on INSERT (delete and update does not affect the view)

                1. Create the target table
                2. Create the materialized view
                    CREATE MATERIALIZED VIEW <>
                    TO <target_table>
                    as
                    <query>


    Aggregations in materialized views:

        AggregatingMergeTree:  Keep for the same Sort Key one row and contains all the numbers i need for the calculation of the aggregations
                               Example: Average by customer:  (2 * 6)+ (3 * 33) istread of 6,6,33,33,33 ===> more compact

                               1. Define the Target table with the AggregatingMergeTree ENGINE
                               2. Define the sort key (aggregation by sort key)
                               3. Define AggregateFunction/SimpleAggregateFunction data type columns
                                        agg_colmn AggregateFunction/SimpleAggregateFunction(<agg_function_min_max_avg_quantile>, datatype)

                               4. Define an Incremetal Materialized View that send the data to target table
                                    The query should GROUP BY the Sort Key of the target table
                                    The aggregations should use State aggregation functions  sumState, avgState
                                    The column names of the query should match the target table column names ( as avg_sales)


                                How to query AggregatingMergeTree:

                                    1. The query should GROUP BY sort key of target table
                                    2. I have to use the relevant Merge aggregate functions (avgMerge, quantileMerge) for AggregateFunction columns
                                    3. I have to use the relevant aggregate functions (sum, min, max) for SimpleAggregateFunction columns

        SummingMergeTree: Same as AggregatingMergeTree but is only summing the numeric columns
                          I dont need to use State and Merge aggregate functions

    Projections: it is transparent from the user, when user use the table the parts of the projection are been used to answer the query
                 In each Part folder we have subfolers for each projection that contains the data of the projection 
                 Clickhouse maintains the Pars of the projection

                 1. ALTE TABLE mytable
                    ADD PROJECTION <projection_name>(

                        select 
                            <col list>
                        ORDER BY town   ---> sort the same data using a different SORT KEY
                    )
                 2. ALTER TABLE mytable MATERIALIZE PROJECTION <projection_name>: this is only once, say to clickhouse to initiate the projection, otherwise we have to wait until the mutation command to finish
                 

                 I can use EXPLAIN to check if the query can utilize the PROJECTION
                 
                 In a PROJECTION i can filter and GROUP if i want

                 Projections can be out of synch (when doing lightweight update/deletes)
                        deduplicate_merge_projection_mode, lightweight_mutation_projection_mode
                        throw:   when goes out of synch throw an exception
                        drop:    when goes out of synch drop the projection and fall to original table
                        rebuild: when goes out of synch rebuild the projection

    Skipping indexes:   Stats per GRANULE to help me skip GRANULE on queries

                Keep values PER GRANULE
                    minmax
                    set: distinct values
                    bloom_filter
                    tokenbf_v1
                    ngrambf_v1

            1. ALTER TABLE mytable
                ADD INDEX <index_name> <columnname>
                TYPE <STAT_TYPE> (N) ---> n values
                granularity 3  ---> per 3 Granules
            2. ALTER TABLE <table_name> MATERIALIZE INDEX <index_name>