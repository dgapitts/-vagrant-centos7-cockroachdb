## Using JSON Data


### Converting from from vehicle_type (STRING) to vehicle_info (JSON)

```
~/projects/vagrant-centos7-cockroachdb $ cockroach sql --host localhost:26257 --insecure --database=movr
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
root@localhost:26257/movr> SELECT id, vehicle_type FROM vehicles LIMIT 1;
                   id                  | vehicle_type
---------------------------------------+---------------
  001d7e32-932c-4b2a-af01-8f31f7a56b09 | scooter
(1 row)

Time: 2ms total (execution 1ms / network 0ms)

root@localhost:26257/movr> ALTER TABLE vehicles ADD COLUMN vehicle_info JSON;
ALTER TABLE

Time: 481ms total (execution 68ms / network 413ms)

root@localhost:26257/movr> SET sql_safe_updates = false;
SET

Time: 0ms total (execution 0ms / network 0ms)

root@localhost:26257/movr> UPDATE
        vehicles
SET
        vehicle_info
                = json_set(
                        vehicle_info,
                        ARRAY['type'],
                        to_json(vehicle_type)
                );
UPDATE 9998

Time: 231ms total (execution 230ms / network 0ms)

root@localhost:26257/movr> SELECT id, vehicle_type FROM vehicles LIMIT 1;
                   id                  | vehicle_type
---------------------------------------+---------------
  001d7e32-932c-4b2a-af01-8f31f7a56b09 | scooter
(1 row)

Time: 1ms total (execution 1ms / network 0ms)

root@localhost:26257/movr> ALTER TABLE vehicles DROP COLUMN vehicle_type;
ALTER TABLE

Time: 2.818s total (execution 0.166s / network 2.652s)

root@localhost:26257/movr> SET sql_safe_updates = true;
SET

Time: 0ms total (execution 0ms / network 0ms)
```

### Reload database to include full JSON 

```
(env) ~/projects/vagrant-centos7-cockroachdb/movr/lab_json $ ./db-setup.sh  'postgres://root@localhost:26257/movr?sslmode=disable'
Using connection string [postgres://root@localhost:26257/movr?sslmode=disable]
Executing [./dbinit.sql]
Loading [./../data/vehicles_data_with_json.sql]
Loading [./../data/location_history_data.sql]
Loading [./../data/users_data.sql]
Loading [./../data/rides_data.sql]
Database setup for this lab is complete.
For details, view db-setup.log.
```


### Using arrow operator to select one key/value

```
root@localhost:26257/movr> 

SELECT
        id,
vehicle_info->'color' AS color
FROM
        vehicles
LIMIT
        10;

                   id                  |  color
---------------------------------------+-----------
  001d7e32-932c-4b2a-af01-8f31f7a56b09 | "yellow"
  002391d6-5804-4dda-b2d1-8660a4f709fa | "black"
  0027e346-1765-4bbf-b67d-f0ed840e15b2 | "yellow"
  003663d4-7505-4b0c-8f0f-32574200b5f4 | "yellow"
  00416e16-5b20-4471-abe3-14a41767178e | "black"
  005ba2ac-e6fd-4013-a636-0a0d3c0a0ab8 | "green"
  0069b125-6151-4860-867a-ad9db7ab9728 | "red"
  00710b1c-cf7e-47ea-bdb3-5786321569c4 | "yellow"
  0074427d-225f-4b3c-9d65-bee8db5a4033 | "green"
  0075f71f-9af9-4641-8392-720f19253c3a | "yellow"
(10 rows)

Time: 10ms total (execution 9ms / network 1ms)
```


### Using multiple arrow operator to select nested key/value

In this example we use two error operators

```
root@localhost:26257/movr> SELECT
        id,
        vehicle_info->'purchase_information'->'purchase_date' AS purchase_date
FROM
        vehicles
LIMIT
        5;
                   id                  |     purchase_date
---------------------------------------+------------------------
  001d7e32-932c-4b2a-af01-8f31f7a56b09 | "2020-03-04 11:01:28"
  002391d6-5804-4dda-b2d1-8660a4f709fa | "2020-06-19 11:38:06"
  0027e346-1765-4bbf-b67d-f0ed840e15b2 | "2020-02-01 02:07:28"
  003663d4-7505-4b0c-8f0f-32574200b5f4 | "2020-04-03 08:35:59"
  00416e16-5b20-4471-abe3-14a41767178e | "2020-07-05 19:13:58"
(5 rows)

Time: 22ms total (execution 20ms / network 2ms)
```


### Using @> operation to select on (where) a key/value pair

```
root@localhost:26257/movr> SELECT count(*)
FROM
        vehicles
WHERE
        vehicle_info @> '{"wear":"damaged"}';
  count
---------
   2409
(1 row)

Time: 107ms total (execution 107ms / network 0ms)

root@localhost:26257/movr> SELECT
        id,
vehicle_info->'wear' as wear
FROM
        vehicles
WHERE
        vehicle_info @> '{"wear":"damaged"}' limit 5;
                   id                  |   wear
---------------------------------------+------------
  001d7e32-932c-4b2a-af01-8f31f7a56b09 | "damaged"
  002391d6-5804-4dda-b2d1-8660a4f709fa | "damaged"
  0027e346-1765-4bbf-b67d-f0ed840e15b2 | "damaged"
  00710b1c-cf7e-47ea-bdb3-5786321569c4 | "damaged"
  00b51d23-cb2e-4d94-b754-28d0905a2e21 | "damaged"
(5 rows)

Time: 12ms total (execution 11ms / network 0ms)
```



### Using @> operation to select on key/value pair PLUS the -> operator to only retrieve specific field values within JSON


First without the -> operator we get the whole JSON object back

```
root@localhost:26257/movr> SELECT
        id,
        vehicle_info
FROM
        vehicles
WHERE
        vehicle_info
        @> '{"purchase_information":{"manufacturer":"Scoot Life"}}' limit 5;
                   id                  |                                                                                     vehicle_info
---------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  002391d6-5804-4dda-b2d1-8660a4f709fa | {"color": "black", "purchase_information": {"manufacturer": "Scoot Life", "purchase_date": "2020-06-19 11:38:06", "serial_number": "12651"}, "type": "scooter", "wear": "damaged"}
  00416e16-5b20-4471-abe3-14a41767178e | {"color": "black", "purchase_information": {"manufacturer": "Scoot Life", "purchase_date": "2020-07-05 19:13:58", "serial_number": "16360"}, "type": "scooter", "wear": "mint"}
  007939eb-757a-4909-b27e-d3ef0fab1966 | {"color": "blue", "purchase_information": {"manufacturer": "Scoot Life", "purchase_date": "2019-12-11 19:17:43", "serial_number": "16426"}, "type": "scooter", "wear": "light wear"}
  00ab43c6-4849-4759-a113-788988ff3924 | {"color": "green", "purchase_information": {"manufacturer": "Scoot Life", "purchase_date": "2019-11-18 15:43:55", "serial_number": "18838"}, "type": "scooter", "wear": "light wear"}
  00e7e0dd-35bf-431d-8d81-1dc142ff5840 | {"color": "blue", "purchase_information": {"manufacturer": "Scoot Life", "purchase_date": "2019-08-01 21:55:15", "serial_number": "13007"}, "type": "scooter", "wear": "heavy wear"}
(5 rows)

Time: 22ms total (execution 7ms / network 15ms)
```

next the -> operator to only retrieve specific field values within JSON

```
root@localhost:26257/movr> SELECT
        id,
        vehicle_info->'purchase_information'->'manufacturer' as manufacturer
FROM
        vehicles
WHERE
        vehicle_info
        @> '{"purchase_information":{"manufacturer":"Scoot Life"}}' limit 5;
                   id                  | manufacturer
---------------------------------------+---------------
  002391d6-5804-4dda-b2d1-8660a4f709fa | "Scoot Life"
  00416e16-5b20-4471-abe3-14a41767178e | "Scoot Life"
  007939eb-757a-4909-b27e-d3ef0fab1966 | "Scoot Life"
  00ab43c6-4849-4759-a113-788988ff3924 | "Scoot Life"
  00e7e0dd-35bf-431d-8d81-1dc142ff5840 | "Scoot Life"
(5 rows)

Time: 2ms total (execution 1ms / network 0ms)
```


### Selecting vehicle_info->'type' for a specific vehicles.id

Final step in the lab:
```
root@localhost:26257/movr> SELECT vehicle_info->'type' AS type
FROM vehicles
WHERE id = '00e8c5c1-c822-496d-9e5a-967c482702dd';
    type
-------------
  "scooter"
(1 row)

Time: 20ms total (execution 11ms / network 9ms)
```