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
