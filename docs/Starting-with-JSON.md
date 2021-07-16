# Starting with JSON


## Simple column conversion to json

```
/Volumes/DaveDrive/learning-cockroach $ cockroach sql --host localhost:26257 --insecure --database=movr
...
root@localhost:26257/movr> ALTER TABLE vehicles ADD COLUMN vehicle_info JSON;
ALTER TABLE

Time: 135ms total (execution 21ms / network 114ms)

root@localhost:26257/movr> UPDATE vehicles SET vehicle_info='{"color": "black", "wear": "mint", "purchase_information": {"purchase_date": "2019-08-02 12:47:04", "manufacturer": "Scoot Life", "serial_number": "10000"}}' WHERE id='3889d3e7-f707-49d6-ac95-749b5ce61263';

UPDATE 1

Time: 10ms total (execution 10ms / network 0ms)

root@localhost:26257/movr>
SELECT * from vehicles WHERE id='3889d3e7-f707-49d6-ac95-749b5ce61263';
                   id                  | battery | in_use | vehicle_type |                                                                         vehicle_info
---------------------------------------+---------+--------+--------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------
  3889d3e7-f707-49d6-ac95-749b5ce61263 |      73 | false  | scooter      | {"color": "black", "purchase_information": {"manufacturer": "Scoot Life", "purchase_date": "2019-08-02 12:47:04", "serial_number": "10000"}, "wear": "mint"}
(1 row)

Time: 1ms total (execution 1ms / network 0ms)
```
Note we're toggleing sql_safe_updates as 'false|true':
```
root@localhost:26257/movr> SET sql_safe_updates = false;

SET

Time: 0ms total (execution 0ms / network 0ms)

root@localhost:26257/movr> UPDATE vehicles SET vehicle_info = json_set(vehicle_info, ARRAY['type'], to_JSON(vehicle_type));

UPDATE 9998

Time: 192ms total (execution 191ms / network 0ms)

root@localhost:26257/movr> SET sql_safe_updates = true;
SET

Time: 0ms total (execution 0ms / network 0ms)

root@localhost:26257/movr> SELECT * FROM vehicles LIMIT 5;
                   id                  | battery | in_use | vehicle_type | vehicle_info
---------------------------------------+---------+--------+--------------+---------------
  001d7e32-932c-4b2a-af01-8f31f7a56b09 |      48 | false  | scooter      | NULL
  002391d6-5804-4dda-b2d1-8660a4f709fa |      80 | false  | scooter      | NULL
  0027e346-1765-4bbf-b67d-f0ed840e15b2 |      66 | false  | scooter      | NULL
  003663d4-7505-4b0c-8f0f-32574200b5f4 |       5 | false  | scooter      | NULL
  00416e16-5b20-4471-abe3-14a41767178e |      85 |  true  | scooter      | NULL
(5 rows)

Time: 2ms total (execution 2ms / network 0ms)
```

## Load more complex JSON dataset

### Reload `movr` database with a JSON specific initial dataset:
```
/Volumes/DaveDrive/learning-cockroach/crdb-perf-basics $ ./db-setup-json.sh  'postgres://root@localhost:26257/movr?sslmode=disable'
Using connection string [postgres://root@localhost:26257/movr?sslmode=disable]
Executing [./data/dbinit_json.sql]
Loading [./data/vehicles_data_with_json.sql]
Loading [./data/users_data.sql]
Database setup for this lab is complete.
For details, view db-setup.log.
```

and now we can query with JSON functions in the WHERE clause 
```
/Volumes/DaveDrive/learning-cockroach/crdb-perf-basics $ cockroach sql --host localhost:26257 --insecure --database=movr
...
root@localhost:26257/movr> SELECT id, vehicle_info->'wear' AS wear
FROM vehicles
WHERE vehicle_info @> '{"wear":"damaged"}' limit 5;
                   id                  |   wear
---------------------------------------+------------
  001d7e32-932c-4b2a-af01-8f31f7a56b09 | "damaged"
  002391d6-5804-4dda-b2d1-8660a4f709fa | "damaged"
  0027e346-1765-4bbf-b67d-f0ed840e15b2 | "damaged"
  00710b1c-cf7e-47ea-bdb3-5786321569c4 | "damaged"
  00b51d23-cb2e-4d94-b754-28d0905a2e21 | "damaged"
(5 rows)

Time: 3ms total (execution 3ms / network 0ms)

root@localhost:26257/movr> explain SELECT id, vehicle_info->'wear' AS wear
FROM vehicles
WHERE vehicle_info @> '{"wear":"damaged"}';
                         info
-------------------------------------------------------
  distribution: full
  vectorized: true

  • render
  │
  └── • filter
      │ filter: vehicle_info @> '{"wear": "damaged"}'
      │
      └── • scan
            missing stats
            table: vehicles@primary
            spans: FULL SCAN
(12 rows)

Time: 1ms total (execution 1ms / network 0ms)

root@localhost:26257/movr> explain analyze SELECT id, vehicle_info->'purchase_information'->'manufacturer' as manufacturer
FROM vehicles
WHERE vehicle_info
        @> '{"purchase_information":{"manufacturer":"Scoot Life"}}';
                                            info
--------------------------------------------------------------------------------------------
  planning time: 458µs
  execution time: 52ms
  distribution: full
  vectorized: true
  rows read from KV: 9,998 (2.4 MiB)
  cumulative time spent in KV: 11ms
  maximum memory usage: 597 KiB
  network usage: 150 KiB (12 messages)

  • render
  │ cluster nodes: n2
  │ actual row count: 3,358
  │ estimated row count: 1,111
  │
  └── • filter
      │ cluster nodes: n2
      │ actual row count: 3,358
      │ estimated row count: 1,111
      │ filter: vehicle_info @> '{"purchase_information": {"manufacturer": "Scoot Life"}}'
      │
      └── • scan
            cluster nodes: n2
            actual row count: 9,998
            KV rows read: 9,998
            KV bytes read: 2.4 MiB
            estimated row count: 9,998 (100% of the table; stats collected 19 seconds ago)
            table: vehicles@primary
            spans: FULL SCAN
(28 rows)

Time: 54ms total (execution 53ms / network 0ms)

root@localhost:26257/movr> explain analyze SELECT * FROM vehicles
WHERE vehicle_info @> '{"purchase_information":{"serial_number":"15695"}}';
                                         info
--------------------------------------------------------------------------------------
  planning time: 378µs
  execution time: 54ms
  distribution: full
  vectorized: true
  rows read from KV: 9,998 (2.4 MiB)
  cumulative time spent in KV: 11ms
  maximum memory usage: 80 KiB
  network usage: 560 B (3 messages)

  • filter
  │ cluster nodes: n2
  │ actual row count: 1
  │ estimated row count: 1,111
  │ filter: vehicle_info @> '{"purchase_information": {"serial_number": "15695"}}'
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

Time: 55ms total (execution 55ms / network 0ms)


Time: 53ms total (execution 53ms / network 0ms)

root@localhost:26257/movr> SELECT * FROM vehicles
WHERE vehicle_info @> '{"purchase_information":{"serial_number":"15695"}}' limit 10;
                   id                  | battery | in_use |                                                                                      vehicle_info
---------------------------------------+---------+--------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ffd43195-82e6-4c1a-9ddf-e14bfabf65dd |      95 | false  | {"color": "yellow", "purchase_information": {"manufacturer": "Scoot Life", "purchase_date": "2020-04-10 03:36:45", "serial_number": "15695"}, "type": "scooter", "wear": "light wear"}
(1 row)

Time: 47ms total (execution 46ms / network 0ms)
```
