## Starting python-dev course with vehicle data with last latitude & longitude

This developer focused course will use a single node cluster
```
[~/projects/vagrant-centos7-cockroachdb] # cat start_cluster_single-node.sh
#!/bin/bash

pkill -9 cockroach
rm -rf ~/projects/vagrant-centos7-cockroachd/node*
# https://www.cockroachlabs.com/docs/v20.2/start-a-local-cluster
# node1
cockroach start-single-node --insecure &

# init
#cockroach init --insecure --host=localhost:26257
#sleep 2
#grep 'node starting' node1/logs/cockroach.log -A 11
#cockroach workload init movr
```


we are setting up "vehicle data with last latitude & longitude"
```
[~/projects/vagrant-centos7-cockroachdb] # cat vehicles_data_with_lat_long.sql
CREATE DATABASE movr;
USE movr;
CREATE TABLE vehicles (
        id UUID PRIMARY KEY,
        last_longitude FLOAT8,
        last_latitude FLOAT8,
        battery INT8,
        last_checkin TIMESTAMP,
        in_use BOOL,
        vehicle_type STRING NOT NULL
    );
INSERT INTO vehicles (id, last_longitude, last_latitude, battery, last_checkin, in_use, vehicle_type) VALUES
	('0001b16c-36b9-4b3f-a2ff-566061f36e03', (-73.91734), 40.61334, 89, '2020-04-30 12:59:15+00:00', false, 'scooter'),
	('00077691-3be2-4440-a34c-f604c9716f99', (-74.42406), 40.70211, 40, '2020-04-30 00:11:08+00:00', false, 'scooter');
```

and running this

```
[~/projects/vagrant-centos7-cockroachdb] # cat vehicles_data_with_lat_long.sql|cockroach sql --host localhost:26257 --insecure 
CREATE DATABASE

Time: 24ms

SET

Time: 13ms

CREATE TABLE

Time: 33ms

INSERT 2

Time: 89ms
```