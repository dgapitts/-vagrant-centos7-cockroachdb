#!/usr/bin/bash

# https://www.cockroachlabs.com/docs/v20.2/start-a-local-cluster
# node1
cockroach start --insecure --store=node1 --listen-addr=localhost:26257 --http-addr=localhost:8080 --join=localhost:26257,localhost:26258,localhost:26259 --background

# node2
cockroach start --insecure --store=node2 --listen-addr=localhost:26258 --http-addr=localhost:8081 --join=localhost:26257,localhost:26258,localhost:26259 --background

# node3
cockroach start --insecure --store=node3 --listen-addr=localhost:26259 --http-addr=localhost:8082 --join=localhost:26257,localhost:26258,localhost:26259 --background

# init
cockroach init --insecure --host=localhost:26257
sleep 5
grep 'node starting' node1/logs/cockroach.log -A 11
