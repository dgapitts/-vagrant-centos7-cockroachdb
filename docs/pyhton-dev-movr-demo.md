## Summary

In the first lesson we only had a couple of vehicle records, however this course appears to have much larger demo sets

### Initial data load based on movr.zip demo files from cockroachdb uni

I've downloaded the demo movr.zip scripts into the movr directory of this repo


```
[~/projects/vagrant-centos7-cockroachdb] # time cat movr/data/vehicles_data_with_lat_long.sql | cockroach sql --host localhost:26257 --insecure

....

INSERT 100

Time: 8ms

INSERT 100

Time: 9ms


real	0m5.136s
user	0m5.428s
sys	0m0.084s
```

### Basic sanity checks on new table


```
[~/projects/vagrant-centos7-cockroachdb] # cockroach sql --host localhost:26257 --insecure
#
# Welcome to the CockroachDB SQL shell.
# All statements must be terminated by a semicolon.
# To exit, type: \q.
#
# Server version: CockroachDB CCL v20.2.7 (x86_64-unknown-linux-gnu, built 2021/03/29 17:52:00, go1.13.14) (same version as client)
# Cluster ID: 3c8b0c00-690c-41e9-aac6-b01ef09c9f7f
#
# Enter \? for a brief introduction.
#
root@localhost:26257/defaultdb> use movr;
SET

Time: 0ms total (execution 0ms / network 0ms)

root@localhost:26257/movr> \l
  database_name | owner
----------------+--------
  defaultdb     | root
  movr          | root
  postgres      | root
  system        | node
(4 rows)

Time: 1ms total (execution 1ms / network 0ms)
```

and checking our new table data 
```
Time: 16ms total (execution 16ms / network 0ms)

root@localhost:26257/movr> \dt vehicles
  schema_name | table_name | type  | owner | estimated_row_count
--------------+------------+-------+-------+----------------------
  public      | vehicles   | table | root  |               10000
(1 row)

Time: 20ms total (execution 20ms / network 0ms)

root@localhost:26257/movr> \d vehicles
   column_name   | data_type | is_nullable | column_default | generation_expression |  indices  | is_hidden
-----------------+-----------+-------------+----------------+-----------------------+-----------+------------
  id             | UUID      |    false    | NULL           |                       | {primary} |   false
  last_longitude | FLOAT8    |    true     | NULL           |                       | {}        |   false
  last_latitude  | FLOAT8    |    true     | NULL           |                       | {}        |   false
  battery        | INT8      |    true     | NULL           |                       | {}        |   false
  last_checkin   | TIMESTAMP |    true     | NULL           |                       | {}        |   false
  in_use         | BOOL      |    true     | NULL           |                       | {}        |   false
  vehicle_type   | STRING    |    false    | NULL           |                       | {}        |   false
(7 rows)

Time: 23ms total (execution 22ms / network 0ms)

root@localhost:26257/movr> select count(*) from vehicles;
  count
---------
  10000
(1 row)

Time: 5ms total (execution 5ms / network 0ms)
```




