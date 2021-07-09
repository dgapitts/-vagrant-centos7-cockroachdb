#   


## FULL SCANs (no index usage)
```
root@localhost:26257/movr> explain SELECT in_use, battery FROM vehicles WHERE in_use = false;
                                         info
---------------------------------------------------------------------------------------
  distribution: full
  vectorized: true

  • filter
  │ estimated row count: 8,990
  │ filter: in_use = false
  │
  └── • scan
        estimated row count: 9,998 (100% of the table; stats collected 8 minutes ago)
        table: vehicles@primary
        spans: FULL SCAN
(11 rows)

Time: 1ms total (execution 1ms / network 0ms)

root@localhost:26257/movr> explain SELECT in_use, battery FROM vehicles WHERE in_use = false AND battery < 9;
                                         info
---------------------------------------------------------------------------------------
  distribution: full
  vectorized: true

  • filter
  │ estimated row count: 803
  │ filter: (in_use = false) AND (battery < 9)
  │
  └── • scan
        estimated row count: 9,998 (100% of the table; stats collected 8 minutes ago)
        table: vehicles@primary
        spans: FULL SCAN
(11 rows)
```

## Reviewing existing indexes

```
Time: 1ms total (execution 1ms / network 0ms)

root@localhost:26257/movr> SHOW INDEXES FROM DATABASE movr;
  table_name | index_name | non_unique | seq_in_index | column_name | direction | storing | implicit
-------------+------------+------------+--------------+-------------+-----------+---------+-----------
  vehicles   | primary    |   false    |            1 | id          | ASC       |  false  |  false
  users      | primary    |   false    |            1 | email       | ASC       |  false  |  false
(2 rows)

Time: 4ms total (execution 4ms / network 0ms)
```

## Add new COMPOSITE index

```
root@localhost:26257/movr> CREATE INDEX ON vehicles(in_use, battery);
CREATE INDEX

Time: 357ms total (execution 20ms / network 338ms)
```

## Review new plan indexes (explain)

```
root@localhost:26257/movr> explain SELECT in_use, battery FROM vehicles WHERE in_use = false AND battery < 9;
                                       info
----------------------------------------------------------------------------------
  distribution: local
  vectorized: true

  • scan
    estimated row count: 803 (8.0% of the table; stats collected 10 minutes ago)
    table: vehicles@vehicles_in_use_battery_idx
    spans: (/false/NULL - /false/8]
(7 rows)

Time: 1ms total (execution 1ms / network 0ms)

root@localhost:26257/movr> explain SELECT in_use, battery FROM vehicles WHERE in_use = false;
                                       info
-----------------------------------------------------------------------------------
  distribution: local
  vectorized: true

  • scan
    estimated row count: 8,990 (90% of the table; stats collected 19 seconds ago)
    table: vehicles@vehicles_in_use_battery_idx
    spans: [/false - /false]
(7 rows)

Time: 1ms total (execution 1ms / network 0ms)
```
## Trace new plan indexes (explain analyze)

```
root@localhost:26257/movr> explain analyze SELECT in_use, battery FROM vehicles WHERE in_use = false;
                                       info
-----------------------------------------------------------------------------------
  planning time: 414µs
  execution time: 10ms
  distribution: local
  vectorized: true
  rows read from KV: 8,990 (413 KiB)
  cumulative time spent in KV: 9ms
  maximum memory usage: 110 KiB
  network usage: 0 B (0 messages)

  • scan
    cluster nodes: n1
    actual row count: 8,990
    KV rows read: 8,990
    KV bytes read: 413 KiB
    estimated row count: 8,990 (90% of the table; stats collected 29 seconds ago)
    table: vehicles@vehicles_in_use_battery_idx
    spans: [/false - /false]
(17 rows)

Time: 12ms total (execution 11ms / network 0ms)

root@localhost:26257/movr> explain analyze SELECT in_use, battery FROM vehicles WHERE in_use = false AND battery < 9;
                                       info
----------------------------------------------------------------------------------
  planning time: 551µs
  execution time: 3ms
  distribution: local
  vectorized: true
  rows read from KV: 761 (35 KiB)
  cumulative time spent in KV: 2ms
  maximum memory usage: 80 KiB
  network usage: 0 B (0 messages)

  • scan
    cluster nodes: n1
    actual row count: 761
    KV rows read: 761
    KV bytes read: 35 KiB
    estimated row count: 763 (7.6% of the table; stats collected 46 seconds ago)
    table: vehicles@vehicles_in_use_battery_idx
    spans: (/false/NULL - /false/8]
(17 rows)

Time: 4ms total (execution 4ms / network 0ms)
```

## Drop index

```
root@localhost:26257/movr> drop INDEX vehicles_in_use_battery_idx;
NOTICE: the data for dropped indexes is reclaimed asynchronously
HINT: The reclamation delay can be customized in the zone configuration for the table.
DROP INDEX

Time: 190ms total (execution 41ms / network 150ms)

root@localhost:26257/movr> SHOW INDEXES FROM DATABASE movr;
  table_name | index_name | non_unique | seq_in_index | column_name | direction | storing | implicit
-------------+------------+------------+--------------+-------------+-----------+---------+-----------
  vehicles   | primary    |   false    |            1 | id          | ASC       |  false  |  false
  users      | primary    |   false    |            1 | email       | ASC       |  false  |  false
(2 rows)

Time: 5ms total (execution 5ms / network 0ms)
```

## Trace original plan without indexes (explain analyze)

```
root@localhost:26257/movr> explain analyze SELECT in_use, battery FROM vehicles WHERE in_use = false AND battery < 9;
                                         info
--------------------------------------------------------------------------------------
  planning time: 818µs
  execution time: 10ms
  distribution: full
  vectorized: true
  rows read from KV: 9,998 (561 KiB)
  cumulative time spent in KV: 7ms
  maximum memory usage: 140 KiB
  network usage: 8.0 KiB (12 messages)

  • filter
  │ cluster nodes: n2
  │ actual row count: 761
  │ estimated row count: 763
  │ filter: (in_use = false) AND (battery < 9)
  │
  └── • scan
        cluster nodes: n2
        actual row count: 9,998
        KV rows read: 9,998
        KV bytes read: 561 KiB
        estimated row count: 9,998 (100% of the table; stats collected 1 minute ago)
        table: vehicles@primary
        spans: FULL SCAN
(23 rows)

Time: 12ms total (execution 12ms / network 0ms)
```

### the data for dropped indexes is reclaimed asynchronously

```
root@localhost:26257/movr> SELECT * FROM [SHOW JOBS] ;
        job_id       |     job_type     |                            description                             | statement | user_name |  status   |   running_status   |          created           |          started           |          finished          |          modified          | fraction_completed | error | coordinator_id
---------------------+------------------+--------------------------------------------------------------------+-----------+-----------+-----------+--------------------+----------------------------+----------------------------+----------------------------+----------------------------+--------------------+-------+-----------------
  673764275672121345 | SCHEMA CHANGE    | CREATE INDEX ON movr.public.vehicles (in_use, battery)             |           | root      | succeeded | NULL               | 2021-07-07 19:42:19.204853 | 2021-07-07 19:42:19.240419 | 2021-07-07 19:42:19.511566 | 2021-07-07 19:42:19.510262 |                  1 |       |           NULL
  673764647426949121 | SCHEMA CHANGE    | DROP INDEX movr.public.vehicles@vehicles_in_use_battery_idx        |           | root      | succeeded | NULL               | 2021-07-07 19:44:12.641214 | 2021-07-07 19:44:12.705512 | 2021-07-07 19:44:12.795633 | 2021-07-07 19:44:12.794137 |                  1 |       |           NULL
  673764647773569025 | SCHEMA CHANGE GC | GC for DROP INDEX movr.public.vehicles@vehicles_in_use_battery_idx |           | root      | running   | waiting for GC TTL | 2021-07-07 19:44:12.762511 | 2021-07-07 19:44:12.788411 | NULL                       | 2021-07-07 19:44:12.797692 |                  0 |       |           NULL
(3 rows)

Time: 4ms total (execution 3ms / network 0ms)
```

