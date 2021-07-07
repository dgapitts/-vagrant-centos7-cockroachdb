# learning-cockroach


## Summary

This repo contains some notes and scripts I've used while working through some cockroachDB courses:
* April 2021 - https://university.cockroachlabs.com/course/introduction-to-distributed-sql-and-cockroachdb
* May 2021 - https://university.cockroachlabs.com/course/practical-first-steps
* June 2021 - https://university.cockroachlabs.com/course/cockroachdb-for-python-developers
* July 2021 - https://university.cockroachlabs.com/course/perfbasics

I started off running centos7-cockroachDB virtualbox-vm via vagrant, which is my favourite way to explore new database technologies:
* Professionally I've been working with Centos 5/6/7 for the last 10+ years (typically running Oracle and Postgres)
* Typically with large relational database engines like Oracle and Postgres there are a large number of package dependencies and sometime kernel level parameter tuning, so have a VM is great

However for learning cockroach, I've steadily migrated from working 
(1) an initial setup with a centos7-cockroachDB virtualbox-vm 
(2) running on old ubuntu 16.04 desktop (easier to configure the WebGUI interface)
(3) running on mac laptop as it was easier to configure the python virtualenv (the python3 version on ubuntu was too out of date?) also installing cockroachdb is simple, clean and fast installation - so much less need to isoloate this in a VM  


## More Details 

### April 2021 (Introduction to Distributed SQL and CockroachDB - Completed April 16, 2021)

Note I started the initial course was run on a vagrant centos7 env


https://university.cockroachlabs.com/course/introduction-to-distributed-sql-and-cockroachdb

* [Base Vagrant Setup (running centos7 cockroachdb v20.2.7) - notes and key points](docs/Base-Vagrant-Setup.md)
* [Exploring demo db - shipped with cockroach](docs/demo_db.md)
* [Introducing the cockroach web-console](docs/Introducing-web-console.md) 


### May 2021 (Practical First Steps with CockroachDB - Completed May 20, 2021)

Note I switched to ubuntu on an old laptop as (a) the web interface wasn't work with vagrant even though I had port forwarding (!?) and (b) the cockroach install is light weight 

https://university.cockroachlabs.com/course/practical-first-steps

* [Transaction management and TransactionAbortedError](docs/Transaction_management.md)
* [Explain plans & secondary indexes](docs/Explain_plans-and-secondary_indexes.md)
* [Starting an Insecure Single-Node Cluster and sample movr datbase](docs/Start-an-Insecure-Single-Node-Cluster.md)
* [Stopping and Removing a Local CockroachDB Cluster via pkill plus data & log files](docs/Stopping-Local-Cockroach-via-pkill.md)
* [Basic CSQL DDL: CREATE & SET database - CREATE & ALTER table - SHOW CREATE](docs/CREATE_SET_DATABASE-CREATE_ALTER_TABLE.md)
* [Introducing web-console part2 - simple load test OLTP vs OLAP on distinct nodes](docs/Introducing-web-console-part2.md)
* [Cluster Concepts: Keyspace-Ranges-Replicas (cover a few key concepts - documentation only)](docs/Cluster-Concepts_Keyspace-Ranges-Replicas.md)
* [Automation to create haproxy for cluster: cockroach gen haproxy ](docs/cockroach-gen-haproxy.md)
* [Starting a 6 node cluster and dead-node rebalancing](docs/6node-cluster-dead-node-rebalanced.md)
* [Working with cockroach node locality](docs/cockroach-node-locality.md)
* [Geo-partitioning basic demo script](docs/geo-partitioning.md)


### June 2021 (Fundamentals of CockroachDB for Python Developers - Completed June 20, 2021)

https://university.cockroachlabs.com/course/cockroachdb-for-python-developers

Note I switched to Mac laptop as (a) the python-sqlalchemy movr project would not install on my old python3.5 env (!?) and (b) the cockroach install is light weight 

* [Getting started for python-dev course with vehicle data with last latitude & longitude](docs/vehicles_data_with_lat_long.md)
* [Initial data load based on movr.zip demo files from cockroachdb uni](docs/pyhton-dev-movr-demo.md)
* [Mac local setup](docs/mac-local-setup.md)
* [Setup python cockroachdb env and first sqlalchemy exercises](docs/setup-python-cockroachdb-env.md)
* [Reviewing sqlalchemy.engine activity and tracing SQL activity](docs/sqlachemy-sql-echo.md)
* [Some referential integrity in CockroachDB](docs/Some-referential-integrity-in-cockroach.md)
* [Adding SQLAchemey Code to eflect schema changes](docs/Adding-SQLAchemey-Code-to-eflect-schema-changes.md)
* [Another RI example and Array Data Type](docs/Array-Data-Type.md)
* [Users and Rides Model and Transaction Handlers](docs/Users-and-Rides-Model-and-Transaction-Handlers.md)
* [Using JSON Data](docs/Using-JSON-Data.md)


## July 2021 (CockroachDB Query Performance for Developers - started in late June 2021)

https://university.cockroachlabs.com/course/perfbasics

* [Example EXPLAIN ANALYZE queries on a Single node setup](docs/Single-node-setup.md)
* [To review distributed query plans we are going to need more one than cluster...](docs/Three-node-setup.md)
* [Composite index demo](docs/composite-index-demo.md)