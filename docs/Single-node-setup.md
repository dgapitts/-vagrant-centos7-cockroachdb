## Single node setup

After downloading / unzip the sample crdb-query-perf.zip code
```
~/projects/vagrant-centos7-cockroachdb/crdb-perf-basics $ time ./db-setup.sh  'postgres://root@localhost:26257/movr?sslmode=disable'
Using connection string [postgres://root@localhost:26257/movr?sslmode=disable]
Executing [./data/dbinit.sql]
Loading [./data/vehicles_data.sql]
Loading [./data/users_data.sql]
Database setup for this lab is complete.
For details, view db-setup.log.

real	0m9.471s
user	0m2.847s
sys	0m1.344s
```
now as per the tutorial validate you have the database setup correctly via a few simple checks

```
~/projects/vagrant-centos7-cockroachdb/crdb-perf-basics $ cockroach sql --host localhost:26257 --insecure --database=movr
#
# Welcome to the CockroachDB SQL shell.
# All statements must be terminated by a semicolon.
# To exit, type: \q.
#
# Server version: CockroachDB CCL v21.1.1 (x86_64-apple-darwin19, built 2021/05/24 15:00:00, go1.15.11) (same version as client)
# Cluster ID: 56d15f0b-2bcb-4dc5-af6f-d4d629a8d843
#
# Enter \? for a brief introduction.
#
root@localhost:26257/movr> \l
  database_name | owner | primary_region | regions | survival_goal
----------------+-------+----------------+---------+----------------
  defaultdb     | root  | NULL           | {}      | NULL
  movr          | root  | NULL           | {}      | NULL
  postgres      | root  | NULL           | {}      | NULL
  system        | node  | NULL           | {}      | NULL
(4 rows)

Time: 2ms total (execution 1ms / network 0ms)

root@localhost:26257/movr> \d
  schema_name | table_name | type  | owner | estimated_row_count | locality
--------------+------------+-------+-------+---------------------+-----------
  public      | users      | table | root  |               10000 | NULL
  public      | vehicles   | table | root  |                9998 | NULL
(2 rows)

Time: 55ms total (execution 55ms / network 0ms)

root@localhost:26257/movr> SELECT count(*) FROM vehicles;
  count
---------
   9998
(1 row)

Time: 18ms total (execution 17ms / network 0ms)

root@localhost:26257/movr> \d vehicles
  column_name  | data_type | is_nullable | column_default | generation_expression |  indices  | is_hidden
---------------+-----------+-------------+----------------+-----------------------+-----------+------------
  id           | UUID      |    false    | NULL           |                       | {primary} |   false
  battery      | INT8      |    true     | NULL           |                       | {}        |   false
  in_use       | BOOL      |    true     | NULL           |                       | {}        |   false
  vehicle_type | STRING    |    false    | NULL           |                       | {}        |   false
(4 rows)

Time: 132ms total (execution 132ms / network 1ms)
```

## Example EXPLAIN ANALYZE queries - on a single node

```
root@localhost:26257/movr> EXPLAIN ANALYZE SELECT * FROM VEHICLES WHERE battery = 0;
                                         info
---------------------------------------------------------------------------------------
  planning time: 4ms
  execution time: 65ms
  distribution: full
  vectorized: true
  rows read from KV: 9,998 (561 KiB)
  cumulative time spent in KV: 40ms
  maximum memory usage: 110 KiB
  network usage: 0 B (0 messages)

  • filter
  │ cluster nodes: n1
  │ actual row count: 102
  │ estimated row count: 102
  │ filter: battery = 0
  │
  └── • scan
        cluster nodes: n1
        actual row count: 9,998
        KV rows read: 9,998
        KV bytes read: 561 KiB
        estimated row count: 9,998 (100% of the table; stats collected 4 minutes ago)
        table: vehicles@primary
        spans: FULL SCAN
(23 rows)

Time: 81ms total (execution 78ms / network 3ms)
```

and

```
root@localhost:26257/movr> EXPLAIN ANALYZE SELECT * FROM VEHICLES LIMIT 1000;
                                       info
----------------------------------------------------------------------------------
  planning time: 2ms
  execution time: 9ms
  distribution: full
  vectorized: true
  rows read from KV: 1,000 (56 KiB)
  cumulative time spent in KV: 4ms
  maximum memory usage: 110 KiB
  network usage: 0 B (0 messages)

  • scan
    cluster nodes: n1
    actual row count: 1,000
    KV rows read: 1,000
    KV bytes read: 56 KiB
    estimated row count: 1,000 (10% of the table; stats collected 5 minutes ago)
    table: vehicles@primary
    spans: LIMITED SCAN
    limit: 1000
(18 rows)

Time: 15ms total (execution 11ms / network 4ms)
```
