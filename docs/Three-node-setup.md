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
