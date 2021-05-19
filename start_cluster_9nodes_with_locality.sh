#!/bin/bash

pkill -9 cockroach
# https://www.cockroachlabs.com/docs/v20.2/start-a-local-cluster

cockroach start --insecure --locality=country=us,region=us-east --store=node1 --listen-addr=localhost:26257 --http-addr=localhost:8080 --join=localhost:26257,localhost:26258,localhost:26259 --background
cockroach start --insecure --locality=country=us,region=us-east --store=node2 --listen-addr=localhost:26258 --http-addr=localhost:8081 --join=localhost:26257,localhost:26258,localhost:26259 --background
cockroach start --insecure --locality=country=us,region=us-east --store=node3 --listen-addr=localhost:26259 --http-addr=localhost:8082 --join=localhost:26257,localhost:26258,localhost:26259 --background

cockroach init --insecure --host=localhost:26257
cockroach start --insecure --locality=country=us,region=us-central --store=node4 --listen-addr=localhost:26260 --http-addr=localhost:8083 --join=localhost:26257,localhost:26258,localhost:26259 --background
cockroach start --insecure --locality=country=us,region=us-central --store=node5 --listen-addr=localhost:26261 --http-addr=localhost:8084 --join=localhost:26257,localhost:26258,localhost:26259 --background
cockroach start --insecure --locality=country=us,region=us-central --store=node6 --listen-addr=localhost:26262 --http-addr=localhost:8085 --join=localhost:26257,localhost:26258,localhost:26259 --background
cockroach start --insecure --locality=country=us,region=us-west --store=node7 --listen-addr=localhost:26263 --http-addr=localhost:8086 --join=localhost:26257,localhost:26258,localhost:26259 --background
cockroach start --insecure --locality=country=us,region=us-west --store=node8 --listen-addr=localhost:26264 --http-addr=localhost:8087 --join=localhost:26257,localhost:26258,localhost:26259 --background
cockroach start --insecure --locality=country=us,region=us-west --store=node9 --listen-addr=localhost:26265 --http-addr=localhost:8088 --join=localhost:26257,localhost:26258,localhost:26259 --background

cockroach workload init movr
cockroach sql --insecure --host=localhost:26257 --execute="SELECT * FROM movr.users LIMIT 10;"
cockroach sql --insecure --host=localhost:26257 --execute="SHOW RANGES FROM TABLE movr.users;"
