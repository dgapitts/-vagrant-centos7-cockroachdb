# Covering Indexes and CREATE INDEX ... STORING <column> clause

## Query Trace - INDEX SCAN  (covering index vehicles_battery_idx)

```
root@localhost:26257/movr> EXPLAIN ANALYZE SELECT battery, id FROM vehicles WHERE battery = 0;
                                      info
--------------------------------------------------------------------------------
  planning time: 488µs
  execution time: 2ms
  distribution: local
  vectorized: true
  rows read from KV: 102 (4.6 KiB)
  cumulative time spent in KV: 1ms
  maximum memory usage: 40 KiB
  network usage: 0 B (0 messages)

  • scan
    cluster nodes: n1
    actual row count: 102
    KV rows read: 102
    KV bytes read: 4.6 KiB
    estimated row count: 102 (1.0% of the table; stats collected 13 hours ago)
    table: vehicles@vehicles_battery_idx
    spans: [/0 - /0]
(17 rows)

Time: 3ms total (execution 3ms / network 0ms)

root@localhost:26257/movr> show indexes from vehicles;
  table_name |      index_name       | non_unique | seq_in_index | column_name | direction | storing | implicit
-------------+-----------------------+------------+--------------+-------------+-----------+---------+-----------
  vehicles   | primary               |   false    |            1 | id          | ASC       |  false  |  false
  vehicles   | vehicles_battery_idx  |    true    |            1 | battery     | ASC       |  false  |  false
  vehicles   | vehicles_battery_idx  |    true    |            2 | id          | ASC       |  false  |   true
```

## Query Trace - INDEX JOIN (non-covering index vehicles_battery_idx) and TABLE SCAN (estimated only 1% of the rows)  

Next adding `in_use` into the SELECT results but not the WHERE clause i.e.:

```
root@localhost:26257/movr> EXPLAIN ANALYZE SELECT battery, id, in_use FROM vehicles WHERE battery = 0;
                                        info
------------------------------------------------------------------------------------
  planning time: 570µs
  execution time: 20ms
  distribution: local
  vectorized: true
  rows read from KV: 204 (10 KiB)
  cumulative time spent in KV: 19ms
  maximum memory usage: 71 KiB
  network usage: 0 B (0 messages)

  • index join
  │ cluster nodes: n1
  │ actual row count: 102
  │ KV rows read: 102
  │ KV bytes read: 5.7 KiB
  │ estimated row count: 102
  │ table: vehicles@primary
  │
  └── • scan
        cluster nodes: n1
        actual row count: 102
        KV rows read: 102
        KV bytes read: 4.6 KiB
        estimated row count: 102 (1.0% of the table; stats collected 13 hours ago)
        table: vehicles@vehicles_battery_idx
        spans: [/0 - /0]
(25 rows)

Time: 21ms total (execution 21ms / network 0ms)
```
## Add index with STORING clause
```
root@localhost:26257/movr> CREATE INDEX ON vehicles (battery) STORING (in_use);
CREATE INDEX

Time: 469ms total (execution 25ms / network 445ms)
```
and the new vehicles_battery_idx1 has id (primary key) implicitly, battery and in_use explicitly (as above). 

The other major difference is that `battery` is part of the index key/sort order where as in_use is stored in the key but not this data is not ordered into the index data, it is just stored with the . This crdb STORING clause, seems similar [postgres non sorted key elements (INCLUDE clause)](https://use-the-index-luke.com/blog/2019-04/include-columns-in-btree-indexes).> 


```
root@localhost:26257/movr> show indexes from vehicles;
  table_name |      index_name       | non_unique | seq_in_index | column_name | direction | storing | implicit
-------------+-----------------------+------------+--------------+-------------+-----------+---------+-----------
  vehicles   | primary               |   false    |            1 | id          | ASC       |  false  |  false
  vehicles   | vehicles_battery_idx  |    true    |            1 | battery     | ASC       |  false  |  false
  vehicles   | vehicles_battery_idx  |    true    |            2 | id          | ASC       |  false  |   true
  vehicles   | vehicles_battery_idx1 |    true    |            1 | battery     | ASC       |  false  |  false
  vehicles   | vehicles_battery_idx1 |    true    |            2 | in_use      | N/A       |  true   |  false
  vehicles   | vehicles_battery_idx1 |    true    |            3 | id          | ASC       |  false  |   true
```
## Query Trace - INDEX SCAN  (covering index vehicles_battery_idx1)

As above the new vehicles_battery_idx1 includes 
```
root@localhost:26257/movr> EXPLAIN ANALYZE SELECT battery, id, in_use FROM vehicles WHERE battery = 0;
                                      info
--------------------------------------------------------------------------------
  planning time: 626µs
  execution time: 2ms
  distribution: local
  vectorized: true
  rows read from KV: 102 (4.7 KiB)
  cumulative time spent in KV: 1ms
  maximum memory usage: 40 KiB
  network usage: 0 B (0 messages)

  • scan
    cluster nodes: n1
    actual row count: 102
    KV rows read: 102
    KV bytes read: 4.7 KiB
    estimated row count: 102 (1.0% of the table; stats collected 13 hours ago)
    table: vehicles@vehicles_battery_idx1
    spans: [/0 - /0]
(17 rows)

Time: 3ms total (execution 3ms / network 0ms)
```

## CRDB supports duplicate indexes

The indexes `vehicles_battery_idx1` and `vehicles_battery_idx2` are identical:

```
root@localhost:26257/movr> show indexes from vehicles;
  table_name |      index_name       | non_unique | seq_in_index | column_name | direction | storing | implicit
-------------+-----------------------+------------+--------------+-------------+-----------+---------+-----------
  vehicles   | primary               |   false    |            1 | id          | ASC       |  false  |  false
  vehicles   | vehicles_battery_idx  |    true    |            1 | battery     | ASC       |  false  |  false
  vehicles   | vehicles_battery_idx  |    true    |            2 | id          | ASC       |  false  |   true
  vehicles   | vehicles_battery_idx1 |    true    |            1 | battery     | ASC       |  false  |  false
  vehicles   | vehicles_battery_idx1 |    true    |            2 | in_use      | N/A       |  true   |  false
  vehicles   | vehicles_battery_idx1 |    true    |            3 | id          | ASC       |  false  |   true
  vehicles   | vehicles_battery_idx2 |    true    |            1 | battery     | ASC       |  false  |  false
  vehicles   | vehicles_battery_idx2 |    true    |            2 | in_use      | N/A       |  true   |  false
  vehicles   | vehicles_battery_idx2 |    true    |            3 | id          | ASC       |  false  |   true
(9 rows)
```

This behaviour is like Postgres but unlike ORACLE. However in Postgres having duplicate indexes was historically highly useful as you could only create indexes CONCURRENTLY and rebuilding existing indexes was a potentially blocking operation. The was fixed in pg12.

However it is not clear to me yet why in CRDB you would ever want to have a duplicate index?
