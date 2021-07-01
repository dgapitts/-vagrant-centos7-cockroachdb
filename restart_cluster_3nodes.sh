#!/bin/bash

cockroach node status --host localhost:26257 --insecure
cockroach start --insecure --background --store=node1 --listen-addr=localhost:26257 --http-addr=localhost:8080 --join=localhost:26257,localhost:26258,localhost:26259
sleep 1; cockroach node status --host localhost:26257 --insecure
cockroach start --insecure --background --store=node2 --listen-addr=localhost:26258 --http-addr=localhost:8081 --join=localhost:26257,localhost:26258,localhost:26259
sleep 1; cockroach node status --host localhost:26257 --insecure
cockroach start --insecure --background --store=node3 --listen-addr=localhost:26259 --http-addr=localhost:8082 --join=localhost:26257,localhost:26258,localhost:26259
sleep 1; cockroach node status --host localhost:26257 --insecure
