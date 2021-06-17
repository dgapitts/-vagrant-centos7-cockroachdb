# Some referential integrity in CockroachDB


## Course notes
In this lesson:
* How to track vehicle histories in MovR
* How to implement a 1:many relationship
* How to implement a foreign key constraint

> Creating a foreign key relationship defines a one-to-many parent/child relationship between the tables. In this example, the vehicles table is considered the parent table. CRDB will enforce this relationship, ensuring that a child row can never reference an invalid parent row. When creating the foreign key column in the child table, you can specify an action to be taken when a row in the parent table which is referenced by a child row is deleted or updated. By default, you will get an error and the row will not be deleted. Use an ON DELETE clause to specify different behavior. This example sets the ON DELETE CASCADE action, which means that when a parent row is deleted, CRDB should also delete all the child rows that reference that parent. You could choose to set the foreign key column value to null or to its default value instead.



## Base setup


Connect to movr database
```
~/projects/vagrant-centos7-cockroachdb $ cockroach sql --host localhost:26257 --insecure
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
root@localhost:26257/defaultdb> use movr;
SET

Time: 1ms total (execution 1ms / network 0ms)

root@localhost:26257/movr> SELECT * FROM movr.vehicles LIMIT 3
;
                   id                  | last_longitude | last_latitude | battery |        last_checkin        | in_use | vehicle_type
---------------------------------------+----------------+---------------+---------+----------------------------+--------+---------------
  00077691-3be2-4440-a34c-f604c9716f99 |      -74.42406 |      40.70211 |      40 | 2021-06-09 18:45:51.582595 |  true  | scooter
  001d7e32-932c-4b2a-af01-8f31f7a56b09 |       -74.2056 |      40.62091 |      48 | 2020-04-29 15:04:13        | false  | scooter
  002391d6-5804-4dda-b2d1-8660a4f709fa |      -74.44846 |      40.72361 |      80 | 2020-04-30 11:43:09        | false  | scooter
(3 rows)

Time: 3ms total (execution 1ms / network 2ms)
```

Create new location_history with ON DELETE CASCADE clause
```
root@localhost:26257/movr> CREATE TABLE location_history (
    id UUID PRIMARY KEY,
    vehicle_id UUID REFERENCES vehicles(id) ON DELETE CASCADE,
    ts TIMESTAMP NOT NULL,
    longitude FLOAT8 NOT NULL,
    latitude FLOAT8 NOT NULL
);
CREATE TABLE

Time: 493ms total (execution 187ms / network 306ms)
```
generate some data in location_history

```
root@localhost:26257/movr> INSERT INTO movr.location_history (id, vehicle_id, ts, longitude, latitude)
SELECT gen_random_uuid(), id, last_checkin, last_longitude, last_latitude
FROM vehicles;
INSERT 10004

Time: 387ms total (execution 386ms / network 0ms)
```

Now if we try to try drop the new columns we hit `sql_safe_updates` checks

```
root@localhost:26257/movr> ALTER TABLE vehicles DROP COLUMN last_checkin,
    DROP COLUMN last_longitude,
    DROP COLUMN last_latitude;
ERROR: rejected (sql_safe_updates = true): ALTER TABLE DROP COLUMN will remove all data in that column
SQLSTATE: 01000
```

We can disable `sql_safe_updates`
```
root@localhost:26257/movr> SET sql_safe_updates = false;
SET

Time: 2ms total (execution 0ms / network 2ms)
root@localhost:26257/movr> ALTER TABLE vehicles DROP COLUMN last_checkin,
    DROP COLUMN last_longitude,
    DROP COLUMN last_latitude;
ALTER TABLE

Time: 1.637s total (execution 0.072s / network 1.565s)

root@localhost:26257/movr> \d vehicles
  column_name  | data_type | is_nullable | column_default | generation_expression |  indices  | is_hidden
---------------+-----------+-------------+----------------+-----------------------+-----------+------------
  id           | UUID      |    false    | NULL           |                       | {primary} |   false
  battery      | INT8      |    true     | NULL           |                       | {}        |   false
  in_use       | BOOL      |    true     | NULL           |                       | {}        |   false
  vehicle_type | STRING    |    false    | NULL           |                       | {}        |   false
(4 rows)

Time: 118ms total (execution 108ms / network 10ms)
```
