## Starting an Insecure Single-Node Cluster and sample movr datbase

Typically I'm a 3-node cluster in vagrant i.e. [cockroachdb_start_cluster.sh](../cockroachdb_start_cluster.sh)

However I had an issue with the 8080 vagrant port forwarding i.e. for the browser/gui tool, so decided to run a local laptop (ubuntu)

```
sudo -i
# https://www.cockroachlabs.com/docs/stable/install-cockroachdb-linux.html
wget -qO- https://binaries.cockroachdb.com/cockroach-v20.2.7.linux-amd64.tgz | tar xvz
cp -i cockroach-v20.2.7.linux-amd64/cockroach /usr/local/bin/
mkdir -p /usr/local/lib/cockroach
cp -i cockroach-v20.2.7.linux-amd64/lib/libgeos.so /usr/local/lib/cockroach/
cp -i cockroach-v20.2.7.linux-amd64/lib/libgeos_c.so /usr/local/lib/cockroach/
```

I wasn't able to start on 8080:

```
[~/projects/local-cockroachdb] # cockroach start --insecure --join=localhost:26257,localhost:26258,localhost:26259 --listen-addr localhost:26257 --http-addr localhost:8080 --store=cockroach-data-1 --background
...
cockroach server exited with error: consider changing the port via --http-addr: listen tcp 127.0.0.1:8080: bind: address already in use
Failed running "start"
E210503 22:08:16.046671 1 cli/error.go:398  ERROR: exit status 1
ERROR: exit status 1
Failed running "start"
```

So started on 8081

```
[~/projects/local-cockroachdb] # cockroach start --insecure --join=localhost:26257,localhost:26258,localhost:26259 --listen-addr localhost:26257 --http-addr localhost:8081 --store=cockroach-data-1 --background
*
* WARNING: ALL SECURITY CONTROLS HAVE BEEN DISABLED!
* 
* This mode is intended for non-production testing only.
* 
* In this mode:
* - Your cluster is open to any client that can access localhost.
* - Intruders with access to your machine or network can observe client-server traffic.
* - Intruders can log in without password and read or write any data in the cluster.
* - Intruders can consume all your server's resources and cause unavailability.
*
*
* INFO: To start a secure server without mandating TLS for clients,
* consider --accept-sql-without-tls instead. For other options, see:
* 
* - https://go.crdb.dev/issue-v/53404/v20.2
* - https://www.cockroachlabs.com/docs/v20.2/secure-a-cluster.html
*
*
* INFO: initial startup completed
* Node will now attempt to join a running cluster, or wait for `cockroach init`.
* Client connections will be accepted after this completes successfully.
* Check the log file(s) for progress. 
*
[~/projects/local-cockroachdb] # 
```

I then run `init`

```
[~/projects/local-cockroachdb] # cockroach init --host localhost:26257 --insecure
Cluster successfully initialized
```
created the movr sample database:
```
[~/projects/local-cockroachdb] # cockroach workload init movr
I210503 22:11:14.540180 1 workload/workloadsql/dataload.go:140  imported users (0s, 50 rows)
I210503 22:11:14.574566 1 workload/workloadsql/dataload.go:140  imported vehicles (0s, 15 rows)
I210503 22:11:14.640406 1 workload/workloadsql/dataload.go:140  imported rides (0s, 500 rows)
I210503 22:11:14.710407 1 workload/workloadsql/dataload.go:140  imported vehicle_location_histories (0s, 1000 rows)
I210503 22:11:14.792999 1 workload/workloadsql/dataload.go:140  imported promo_codes (0s, 1000 rows)
I210503 22:11:14.797233 1 workload/workloadsql/workloadsql.go:113  starting 8 splits
I210503 22:11:14.979613 1 workload/workloadsql/workloadsql.go:113  starting 8 splits
I210503 22:11:15.115228 1 workload/workloadsql/workloadsql.go:113  starting 8 splits
```
and using `sql` tool

```
[~/projects/local-cockroachdb] # cockroach sql --host localhost:26257 --insecure
#
# Welcome to the CockroachDB SQL shell.
# All statements must be terminated by a semicolon.
# To exit, type: \q.
#
# Server version: CockroachDB CCL v20.2.7 (x86_64-unknown-linux-gnu, built 2021/03/29 17:52:00, go1.13.14) (same version as client)
# Cluster ID: 9b4bb44a-8829-44cf-8a19-3ea90b284a8a
#
# Enter \? for a brief introduction.
#
root@localhost:26257/defaultdb> \l
  database_name | owner
----------------+--------
  defaultdb     | root
  movr          | root
  postgres      | root
  system        | node
(4 rows)

Time: 2ms total (execution 2ms / network 0ms)

root@localhost:26257/defaultdb> 
```




