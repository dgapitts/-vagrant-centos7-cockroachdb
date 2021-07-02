## Summary

To review distributed query plans we are going to need more one than cluster

## start_cluster_3nodes.sh - building / rebuiling cluster (automated cleanup of previous install i.e. wiping any existing data)
```
~/projects/vagrant-centos7-cockroachdb $ cat start_cluster_3nodes.sh
#!/bin/bash

pkill -9 cockroach
# https://www.cockroachlabs.com/docs/v20.2/start-a-local-cluster
# node1


mkdir -p node1
mkdir -p node2
mkdir -p node3

cockroach start --insecure --background --store=node1 --listen-addr=localhost:26257 --http-addr=localhost:8080 --join=localhost:26257,localhost:26258,localhost:26259
cockroach start --insecure --background --store=node2 --listen-addr=localhost:26258 --http-addr=localhost:8081 --join=localhost:26257,localhost:26258,localhost:26259
cockroach start --insecure --background --store=node3 --listen-addr=localhost:26259 --http-addr=localhost:8082 --join=localhost:26257,localhost:26258,localhost:26259
cockroach init --insecure --host=localhost:26257
cockroach sql --execute="SET CLUSTER SETTING server.time_until_store_dead = '1m15s';" --insecure

#cockroach workload init movr
```

## restart_cluster_3nodes.sh - restart previous installtion (preserving old data)


```
~/projects/vagrant-centos7-cockroachdb $ cat restart_cluster_3nodes.sh
#!/bin/bash

cockroach node status --host localhost:26257 --insecure
cockroach start --insecure --background --store=node1 --listen-addr=localhost:26257 --http-addr=localhost:8080 --join=localhost:26257,localhost:26258,localhost:26259
sleep 1; cockroach node status --host localhost:26257 --insecure
cockroach start --insecure --background --store=node2 --listen-addr=localhost:26258 --http-addr=localhost:8081 --join=localhost:26257,localhost:26258,localhost:26259
sleep 1; cockroach node status --host localhost:26257 --insecure
cockroach start --insecure --background --store=node3 --listen-addr=localhost:26259 --http-addr=localhost:8082 --join=localhost:26257,localhost:26258,localhost:26259
sleep 1; cockroach node status --host localhost:26257 --insecure
```






## Reloading `crdb-perf-basics` data
```
~/projects/vagrant-centos7-cockroachdb/crdb-perf-basics $ ./db-setup.sh  'postgres://root@localhost:26257/movr?sslmode=disable'
Using connection string [postgres://root@localhost:26257/movr?sslmode=disable]
Executing [./data/dbinit.sql]
Loading [./data/vehicles_data.sql]
Loading [./data/users_data.sql]
Database setup for this lab is complete.
For details, view db-setup.log.

real	0m13.941s
user	0m3.047s
sys	0m1.486s
```



This is interesting, initially we have stale stats

```
~/projects/vagrant-centos7-cockroachdb/crdb-perf-basics $ cockroach sql --host localhost:26257 --insecure --database=movr
…

root@localhost:26257/movr> \d
  schema_name | table_name | type  | owner | estimated_row_count | locality
--------------+------------+-------+-------+---------------------+-----------
  public      | users      | table | root  |                   0 | NULL
  public      | vehicles   | table | root  |                   0 | NULL
(2 rows)

Time: 115ms total (execution 115ms / network 0ms)

root@localhost:26257/movr> SELECT count(*) FROM vehicles;
  count
---------
   9998
(1 row)

Time: 9ms total (execution 8ms / network 1ms)
```

But this soon gets resolved 


```

root@localhost:26257/movr> \d
  schema_name | table_name | type  | owner | estimated_row_count | locality
--------------+------------+-------+-------+---------------------+-----------
  public      | users      | table | root  |               10000 | NULL
  public      | vehicles   | table | root  |                9998 | NULL
(2 rows)

Time: 87ms total (execution 86ms / network 1ms)
```
