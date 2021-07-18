# Demo INVERTED INDEX 

## reload tst schema and data via  ./db-setup-json.sh 

```
learning-cockroach/crdb-perf-basics $ ./db-setup-json.sh  'postgres://root@localhost:26257/movr?sslmode=disable'
Using connection string [postgres://root@localhost:26257/movr?sslmode=disable]
Executing [./data/dbinit_json.sql]
Loading [./data/vehicles_data_with_json.sql]
Loading [./data/users_data.sql]
Database setup for this lab is complete.
For details, view db-setup.log.
```


## query on  `vehicles where vehicle_info @> '{"wear":"damaged"}` uses `FULL SCAN` on `table: vehicles@primary` 
```
learning-cockroach/crdb-perf-basics $ cockroach sql --host localhost:26257 --insecure --database=movr
...
# Enter \? for a brief introduction.
#
root@localhost:26257/movr> \d vehicles
  column_name  | data_type | is_nullable | column_default | generation_expression |  indices  | is_hidden
---------------+-----------+-------------+----------------+-----------------------+-----------+------------
  id           | UUID      |    false    | NULL           |                       | {primary} |   false
  battery      | INT8      |    true     | NULL           |                       | {}        |   false
  in_use       | BOOL      |    true     | NULL           |                       | {}        |   false
  vehicle_info | JSONB     |    true     | NULL           |                       | {}        |   false
(4 rows)

Time: 24ms total (execution 23ms / network 0ms)

root@localhost:26257/movr> explain analyze select * from vehicles where vehicle_info @> '{"wear":"damaged"}';
                                          info
----------------------------------------------------------------------------------------
  planning time: 439µs
  execution time: 52ms
  distribution: full
  vectorized: true
  rows read from KV: 9,998 (2.4 MiB)
  cumulative time spent in KV: 12ms
  maximum memory usage: 232 KiB
  network usage: 548 KiB (12 messages)

  • filter
  │ cluster nodes: n2
  │ actual row count: 2,409
  │ estimated row count: 1,111
  │ filter: vehicle_info @> '{"wear": "damaged"}'
  │
  └── • scan
        cluster nodes: n2
        actual row count: 9,998
        KV rows read: 9,998
        KV bytes read: 2.4 MiB
        estimated row count: 9,998 (100% of the table; stats collected 27 seconds ago)
        table: vehicles@primary
        spans: FULL SCAN
(23 rows)

Time: 53ms total (execution 53ms / network 0ms)
```

## Add INVERTED INDEX ON vehicles (vehicle_info);
```
root@localhost:26257/movr> CREATE INVERTED INDEX ON vehicles (vehicle_info);
CREATE INDEX

Time: 982ms total (execution 21ms / network 961ms)
```

##  show indexes from vehicles - inspect new vehicles_vehicle_info_idx
```
root@localhost:26257/movr> show indexes from vehicles;
  table_name |        index_name         | non_unique | seq_in_index | column_name  | direction | storing | implicit
-------------+---------------------------+------------+--------------+--------------+-----------+---------+-----------
  vehicles   | primary                   |   false    |            1 | id           | ASC       |  false  |  false
  vehicles   | vehicles_vehicle_info_idx |    true    |            1 | vehicle_info | ASC       |  false  |  false
  vehicles   | vehicles_vehicle_info_idx |    true    |            2 | id           | ASC       |  false  |   true
(3 rows)

Time: 5ms total (execution 5ms / network 0ms)
```

## query on  `vehicles where vehicle_info @> '{"wear":"damaged"}` uses INDEX SCAN on `table: vehicles@vehicles_vehicle_info_idx` 

```
root@localhost:26257/movr> explain analyze select * from vehicles where vehicle_info @> '{"wear":"damaged"}';
                                        info
-------------------------------------------------------------------------------------
  planning time: 254µs
  execution time: 72ms
  distribution: local
  vectorized: true
  rows read from KV: 4,818 (729 KiB)
  cumulative time spent in KV: 66ms
  maximum memory usage: 1.1 MiB
  network usage: 0 B (0 messages)

  • index join
  │ cluster nodes: n1
  │ actual row count: 2,409
  │ KV rows read: 2,409
  │ KV bytes read: 583 KiB
  │ estimated row count: 1,111
  │ table: vehicles@primary
  │
  └── • scan
        cluster nodes: n1
        actual row count: 2,409
        KV rows read: 2,409
        KV bytes read: 146 KiB
        estimated row count: 1,111 (11% of the table; stats collected 1 minute ago)
        table: vehicles@vehicles_vehicle_info_idx
        spans: 1 span
(25 rows)

Time: 73ms total (execution 73ms / network 0ms)

root@localhost:26257/movr>
```