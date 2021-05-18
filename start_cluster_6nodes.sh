#!/bin/bash

pkill -9 cockroach
# https://www.cockroachlabs.com/docs/v20.2/start-a-local-cluster
# node1


mkdir -p node1
mkdir -p node2
mkdir -p node3
mkdir -p node4
mkdir -p node5
mkdir -p node6

cockroach start --insecure --background --store=node1 --listen-addr=localhost:26257 --http-addr=localhost:8080 --join=localhost:26257,localhost:26258,localhost:26259,localhost:26260,localhost:26261,localhost:26262
cockroach start --insecure --background --store=node2 --listen-addr=localhost:26258 --http-addr=localhost:8081 --join=localhost:26257,localhost:26258,localhost:26259,localhost:26260,localhost:26261,localhost:26262
cockroach start --insecure --background --store=node3 --listen-addr=localhost:26259 --http-addr=localhost:8082 --join=localhost:26257,localhost:26258,localhost:26259,localhost:26260,localhost:26261,localhost:26262
cockroach start --insecure --background --store=node4 --listen-addr=localhost:26260 --http-addr=localhost:8083 --join=localhost:26257,localhost:26258,localhost:26259,localhost:26260,localhost:26261,localhost:26262
cockroach start --insecure --background --store=node5 --listen-addr=localhost:26261 --http-addr=localhost:8084 --join=localhost:26257,localhost:26258,localhost:26259,localhost:26260,localhost:26261,localhost:26262
cockroach start --insecure --background --store=node6 --listen-addr=localhost:26262 --http-addr=localhost:8085 --join=localhost:26257,localhost:26258,localhost:26259,localhost:26260,localhost:26261,localhost:26262
cockroach init --insecure --host=localhost:26257
cockroach sql --execute="SET CLUSTER SETTING server.time_until_store_dead = '1m15s';" --insecure

cockroach workload init movr
