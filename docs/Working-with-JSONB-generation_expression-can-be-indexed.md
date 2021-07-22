## Working with JSONB - generation_expression (aka computed columns) - can be indexed

### Initil vehicle table with JSONB vehicle_info 

```
learning-cockroach $ cockroach sql --host localhost:26257 --insecure --database=movr
# Server version: CockroachDB CCL v21.1.1 (x86_64-apple-darwin19, built 2021/05/24 15:00:00, go1.15.11) (same version as client)
# Cluster ID: c4022c99-2f4c-42d1-a577-67647a66f4fd
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

Time: 26ms total (execution 25ms / network 0ms)
```

### Add computed column serial_number based on JSONB vehicle_info
```
root@localhost:26257/movr> ALTER TABLE vehicles ADD COLUMN serial_number INT AS ((vehicle_info->'purchase_information'->>'serial_number')::INT8) STORED;
ALTER TABLE

Time: 937ms total (execution 25ms / network 912ms)
```

### Describe vehicle table again (now with serial_number generation_expression)
```
root@localhost:26257/movr> \d vehicles
   column_name  | data_type | is_nullable | column_default |                      generation_expression                       |  indices  | is_hidden
----------------+-----------+-------------+----------------+------------------------------------------------------------------+-----------+------------
  id            | UUID      |    false    | NULL           |                                                                  | {primary} |   false
  battery       | INT8      |    true     | NULL           |                                                                  | {}        |   false
  in_use        | BOOL      |    true     | NULL           |                                                                  | {}        |   false
  vehicle_info  | JSONB     |    true     | NULL           |                                                                  | {}        |   false
  serial_number | INT8      |    true     | NULL           | ((vehicle_info->'purchase_information')->>'serial_number')::INT8 | {}        |   false
(5 rows)

Time: 24ms total (execution 24ms / network 0ms)
```

### review SELECT * FROM [SHOW JOBS]
```
root@localhost:26257/movr> SELECT * FROM [SHOW JOBS] ;
        job_id       |   job_type    |                                                                 description                                                                 | statement | user_name |  status   | running_status |          created           |          started          |          finished          |          modified          | fraction_completed | error | coordinator_id
---------------------+---------------+---------------------------------------------------------------------------------------------------------------------------------------------+-----------+-----------+-----------+----------------+----------------------------+---------------------------+----------------------------+----------------------------+--------------------+-------+-----------------
  677976170226122753 | SCHEMA CHANGE | ALTER TABLE movr.public.vehicles ADD COLUMN serial_number INT8 AS (((vehicle_info->'purchase_information')->>'serial_number')::INT8) STORED |           | root      | succeeded | NULL           | 2021-07-22 16:45:07.415103 | 2021-07-22 16:45:07.45675 | 2021-07-22 16:45:08.257523 | 2021-07-22 16:45:08.256474 |                  1 |       |           NULL
(1 row)

Time: 9ms total (execution 9ms / network 0ms)
```
## EXPLAIN ANALYZE for query using serial_number (generation_expression) - full table scan
```
root@localhost:26257/movr> EXPLAIN ANALYZE SELECT id, serial_number FROM vehicles WHERE serial_number <= 11000 AND serial_number > 10500;
                                         info
--------------------------------------------------------------------------------------
  planning time: 679µs
  execution time: 14ms
  distribution: full
  vectorized: true
  rows read from KV: 9,998 (2.4 MiB)
  cumulative time spent in KV: 11ms
  maximum memory usage: 130 KiB
  network usage: 16 KiB (12 messages)

  • filter
  │ cluster nodes: n2
  │ actual row count: 500
  │ estimated row count: 500
  │ filter: (serial_number <= 11000) AND (serial_number > 10500)
  │
  └── • scan
        cluster nodes: n2
        actual row count: 9,998
        KV rows read: 9,998
        KV bytes read: 2.4 MiB
        estimated row count: 9,998 (100% of the table; stats collected 1 minute ago)
        table: vehicles@primary
        spans: FULL SCAN
(23 rows)

Time: 15ms total (execution 15ms / network 0ms)
```

### Add index to computed column serial_number 

```
root@localhost:26257/movr> CREATE INDEX ON vehicles (serial_number);
CREATE INDEX

Time: 362ms total (execution 25ms / network 337ms)
```

### review SELECT * FROM [SHOW JOBS] again

```
root@localhost:26257/movr> SELECT * FROM [SHOW JOBS] ;
        job_id       |   job_type    |                                                                 description                                                                 | statement | user_name |  status   | running_status |          created           |          started           |          finished          |          modified          | fraction_completed | error | coordinator_id
---------------------+---------------+---------------------------------------------------------------------------------------------------------------------------------------------+-----------+-----------+-----------+----------------+----------------------------+----------------------------+----------------------------+----------------------------+--------------------+-------+-----------------
  677976170226122753 | SCHEMA CHANGE | ALTER TABLE movr.public.vehicles ADD COLUMN serial_number INT8 AS (((vehicle_info->'purchase_information')->>'serial_number')::INT8) STORED |           | root      | succeeded | NULL           | 2021-07-22 16:45:07.415103 | 2021-07-22 16:45:07.45675  | 2021-07-22 16:45:08.257523 | 2021-07-22 16:45:08.256474 |                  1 |       |           NULL
  677976769563590657 | SCHEMA CHANGE | CREATE INDEX ON movr.public.vehicles (serial_number)                                                                                        |           | root      | succeeded | NULL           | 2021-07-22 16:48:10.31929  | 2021-07-22 16:48:10.360576 | 2021-07-22 16:48:10.639419 | 2021-07-22 16:48:10.638485 |                  1 |       |           NULL
(2 rows)

Time: 4ms total (execution 4ms / network 0ms)
```

## EXPLAIN ANALYZE for query using serial_number (generation_expression) - index scan now
```
root@localhost:26257/movr> EXPLAIN ANALYZE SELECT id, serial_number FROM vehicles WHERE serial_number <= 11000 AND serial_number > 10500;
                                      info
---------------------------------------------------------------------------------
  planning time: 821µs
  execution time: 2ms
  distribution: local
  vectorized: true
  rows read from KV: 500 (24 KiB)
  cumulative time spent in KV: 2ms
  maximum memory usage: 98 KiB
  network usage: 0 B (0 messages)

  • scan
    cluster nodes: n1
    actual row count: 500
    KV rows read: 500
    KV bytes read: 24 KiB
    estimated row count: 500 (5.0% of the table; stats collected 2 minutes ago)
    table: vehicles@vehicles_serial_number_idx
    spans: [/10501 - /11000]
(17 rows)

Time: 4ms total (execution 4ms / network 0ms)
```
### Finally show indexes from vehicles
```
root@localhost:26257/movr> show indexes from vehicles;
  table_name |         index_name         | non_unique | seq_in_index |  column_name  | direction | storing | implicit
-------------+----------------------------+------------+--------------+---------------+-----------+---------+-----------
  vehicles   | primary                    |   false    |            1 | id            | ASC       |  false  |  false
  vehicles   | vehicles_serial_number_idx |    true    |            1 | serial_number | ASC       |  false  |  false
  vehicles   | vehicles_serial_number_idx |    true    |            2 | id            | ASC       |  false  |   true
(3 rows)

Time: 5ms total (execution 5ms / network 0ms)
```