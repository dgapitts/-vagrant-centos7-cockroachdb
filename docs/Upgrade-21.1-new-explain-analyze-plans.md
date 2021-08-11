## Upgrading to 21.1 and newer explain analyze plan format

As my cluster was on the old 20.2 and I wanted the newer explain analyze plans:

```
root@localhost:26257/tpcc> explain analyze select max(ol_delivery_d) from order_line;
                                           info
-------------------------------------------------------------------------------------------
  planning time: 268µs
  execution time: 1.7s
  distribution: full
  vectorized: true
  rows read from KV: 3,001,222 (216 MiB)
  cumulative time spent in KV: 2.8s
  maximum memory usage: 346 KiB
  network usage: 368 B (6 messages)

  • group (scalar)
  │ nodes: n1
  │ actual row count: 1
  │ estimated row count: 1
  │
  └── • scan
        nodes: n1, n2, n3
        actual row count: 3,001,222
        KV rows read: 3,001,222
        KV bytes read: 216 MiB
        estimated row count: 3,001,222 (100% of the table; stats collected 8 minutes ago)
        table: order_line@primary
        spans: FULL SCAN
(22 rows)

Time: 1.689s total (execution 1.688s / network 0.000s)
```

I basically worked through the upgrade process

>  https://www.cockroachlabs.com/docs/stable/upgrade-cockroach-version.html?filters=linux


I've pasted some details below:
* interesting that using `pkill cockroach` command, despite its brutual name, it still drains the cluster (needs a bit more research)
```
[/tmp] # pkill cockroach
initiating graceful shutdown of server
initiating graceful shutdown of server
[/tmp] # initiating graceful shutdown of server
server drained and shutdown completed
server drained and shutdown completed
```
* I recommend using wget instead of curl (which spammed my terminal)
```
wget https://binaries.cockroachdb.com/cockroach-v21.1.6.linux-amd64.tgz
```
* I also had to explicit add sudo replace the old binary
```
sudo cp -i cockroach-v21.1.6.linux-amd64/cockroach /usr/local/bin/cockroach
```
* I also made a bit of mess of my current cluster but not using the full path (I downloaded the new binary tar file to /tmp and forgot to move back to project directory)
```
[/tmp] # sleep 1; cockroach node status --host localhost:26257 --insecure
  id |     address     |   sql_address   |  build  |         started_at         |         updated_at         | locality | is_available | is_live
-----+-----------------+-----------------+---------+----------------------------+----------------------------+----------+--------------+----------
   1 | localhost:26257 | localhost:26257 | v20.2.7 | 2021-08-08 20:20:38.096553 | 2021-08-11 19:27:56.163778 |          | false        | false
   2 | localhost:26258 | localhost:26258 | v20.2.7 | 2021-08-11 19:27:41.118193 | 2021-08-11 19:35:11.189585 |          | true         | true
   3 | localhost:26259 | localhost:26259 | v20.2.7 | 2021-08-11 19:27:43.102649 | 2021-08-11 19:35:13.195061 |          | true         | true
   4 | localhost:26257 | localhost:26257 | v21.1.6 | 2021-08-11 19:35:12.268839 | 2021-08-11 19:35:12.322236 |          | true         | true
(4 rows)
```
* As I messed up my tpcc custer - I simply rebuilt it and now it is on 21.1
```
[~/projects/learning-cockroach] # cat start_cluster_3nodes_tpcc.sh 
#!/bin/bash

pkill -9 cockroach
# https://www.cockroachlabs.com/docs/v20.2/start-a-local-cluster
# node1

# remove previous cockroach setup 
rm -rf node*
mkdir -p node1
mkdir -p node2
mkdir -p node3

cockroach start --insecure --background --store=node1 --listen-addr=localhost:26257 --http-addr=localhost:8080 --join=localhost:26257,localhost:26258,localhost:26259
cockroach start --insecure --background --store=node2 --listen-addr=localhost:26258 --http-addr=localhost:8081 --join=localhost:26257,localhost:26258,localhost:26259
cockroach start --insecure --background --store=node3 --listen-addr=localhost:26259 --http-addr=localhost:8082 --join=localhost:26257,localhost:26258,localhost:26259
cockroach init --insecure --host=localhost:26257

cockroach sql --execute="SET CLUSTER SETTING server.time_until_store_dead = '1m15s';" --insecure

#cockroach workload init movr
cockroach workload fixtures import tpcc --warehouses=10 'postgresql://root@localhost:26257?sslmode=disable'

sleep 1; cockroach node status --host localhost:26257 --insecure
[~/projects/learning-cockroach] # ./start_cluster_3nodes_tpcc.sh
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
* - https://go.crdb.dev/issue-v/53404/v21.1
* - https://www.cockroachlabs.com/docs/v21.1/secure-a-cluster.html
*
*
* INFO: initial startup completed.
* Node will now attempt to join a running cluster, or wait for `cockroach init`.
* Client connections will be accepted after this completes successfully.
* Check the log file(s) for progress. 
*
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
* - https://go.crdb.dev/issue-v/53404/v21.1
* - https://www.cockroachlabs.com/docs/v21.1/secure-a-cluster.html
*
*
* INFO: initial startup completed.
* Node will now attempt to join a running cluster, or wait for `cockroach init`.
* Client connections will be accepted after this completes successfully.
* Check the log file(s) for progress. 
*
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
* - https://go.crdb.dev/issue-v/53404/v21.1
* - https://www.cockroachlabs.com/docs/v21.1/secure-a-cluster.html
*
*
* INFO: initial startup completed.
* Node will now attempt to join a running cluster, or wait for `cockroach init`.
* Client connections will be accepted after this completes successfully.
* Check the log file(s) for progress. 
*
Cluster successfully initialized
SET CLUSTER SETTING

Time: 23ms

I210811 20:01:33.116106 1 ccl/workloadccl/fixture.go:342  [-] 1  starting import of 9 tables
I210811 20:01:33.919256 23 ccl/workloadccl/fixture.go:472  [-] 2  imported 529 B in warehouse table (10 rows, 0 index entries, took 762.138611ms, 0.00 MiB/s)
I210811 20:01:36.699628 24 ccl/workloadccl/fixture.go:472  [-] 3  imported 9.9 KiB in district table (100 rows, 0 index entries, took 3.542165183s, 0.00 MiB/s)
I210811 20:01:43.107443 29 ccl/workloadccl/fixture.go:472  [-] 4  imported 7.8 MiB in item table (100000 rows, 0 index entries, took 9.949650745s, 0.78 MiB/s)
I210811 20:01:43.759044 28 ccl/workloadccl/fixture.go:472  [-] 5  imported 1.1 MiB in new_order table (90000 rows, 0 index entries, took 10.601387612s, 0.11 MiB/s)
I210811 20:01:57.530860 27 ccl/workloadccl/fixture.go:472  [-] 6  imported 15 MiB in order table (300000 rows, 300000 index entries, took 24.373350961s, 0.62 MiB/s)
I210811 20:01:59.692794 26 ccl/workloadccl/fixture.go:472  [-] 7  imported 22 MiB in history table (300000 rows, 0 index entries, took 26.535421537s, 0.81 MiB/s)
I210811 20:02:07.360732 25 ccl/workloadccl/fixture.go:472  [-] 8  imported 176 MiB in customer table (300000 rows, 300000 index entries, took 34.203652281s, 5.13 MiB/s)
I210811 20:02:11.943563 30 ccl/workloadccl/fixture.go:472  [-] 9  imported 306 MiB in stock table (1000000 rows, 0 index entries, took 38.785633539s, 7.89 MiB/s)
I210811 20:02:12.691202 31 ccl/workloadccl/fixture.go:472  [-] 10  imported 165 MiB in order_line table (3001222 rows, 0 index entries, took 39.534022026s, 4.17 MiB/s)
I210811 20:02:12.848856 1 ccl/workloadccl/fixture.go:351  [-] 11  imported 692 MiB bytes in 9 tables (took 39.732527707s, 17.41 MiB/s)
I210811 20:02:17.119276 1 ccl/workloadccl/cliccl/fixtures.go:355  [-] 12  fixture is restored; now running consistency checks (ctrl-c to abort)
I210811 20:02:17.284675 1 workload/tpcc/tpcc.go:389  [-] 13  check 3.3.2.1 took 165.306834ms
I210811 20:02:18.076053 1 workload/tpcc/tpcc.go:389  [-] 14  check 3.3.2.2 took 791.31152ms
I210811 20:02:18.236067 1 workload/tpcc/tpcc.go:389  [-] 15  check 3.3.2.3 took 159.953661ms
I210811 20:02:21.630895 1 workload/tpcc/tpcc.go:389  [-] 16  check 3.3.2.4 took 3.39465596s
I210811 20:02:22.248618 1 workload/tpcc/tpcc.go:389  [-] 17  check 3.3.2.5 took 617.676528ms
I210811 20:02:24.657715 1 workload/tpcc/tpcc.go:389  [-] 18  check 3.3.2.7 took 2.409040017s
I210811 20:02:25.060904 1 workload/tpcc/tpcc.go:389  [-] 19  check 3.3.2.8 took 403.145828ms
I210811 20:02:25.461723 1 workload/tpcc/tpcc.go:389  [-] 20  check 3.3.2.9 took 400.776077ms
  id |     address     |   sql_address   |  build  |         started_at         |         updated_at         | locality | is_available | is_live
-----+-----------------+-----------------+---------+----------------------------+----------------------------+----------+--------------+----------
   1 | localhost:26257 | localhost:26257 | v21.1.6 | 2021-08-11 20:01:32.21374  | 2021-08-11 20:02:26.247194 |          | true         | true
   2 | localhost:26258 | localhost:26258 | v21.1.6 | 2021-08-11 20:01:32.624001 | 2021-08-11 20:02:23.086661 |          | true         | true
   3 | localhost:26259 | localhost:26259 | v21.1.6 | 2021-08-11 20:01:32.924349 | 2021-08-11 20:02:23.086665 |          | true         | true
(3 rows)
[~/projects/learning-cockroach] # cockroach sql --host localhost:26257 --insecure 
#
# Welcome to the CockroachDB SQL shell.
# All statements must be terminated by a semicolon.
# To exit, type: \q.
#
# Server version: CockroachDB CCL v21.1.6 (x86_64-unknown-linux-gnu, built 2021/07/20 15:30:39, go1.15.11) (same version as client)
# Cluster ID: cec4fe37-1f82-43d2-bcee-57da19eb4e84
#
# Enter \? for a brief introduction.
#
root@localhost:26257/defaultdb> \l
  database_name | owner | primary_region | regions | survival_goal
----------------+-------+----------------+---------+----------------
  defaultdb     | root  | NULL           | {}      | NULL
  postgres      | root  | NULL           | {}      | NULL
  system        | node  | NULL           | {}      | NULL
  tpcc          | root  | NULL           | {}      | NULL
(4 rows)

Time: 6ms total (execution 5ms / network 1ms)
```

### Details - upgrade commands and niggly issues



```
  519  cockroach sql --insecure --host=localhost:26257 --execute="SET CLUSTER SETTING cluster.preserve_downgrade_option = '20.2';"
  520  ps aux | grep cockroach
  521  cockroach status --insecure --store=node1 --listen-addr=localhost:26257 --http-addr=localhost:8080 --join=localhost:26257,localhost:26258,localhost:26259
  522  pkill cockroach
  523  cd /tmp
  524  curl https://binaries.cockroachdb.com/cockroach-v21.1.6.linux-amd64.tgz
  525  history
[/tmp] # cp ~/cockroach-v21.1.6.linux-amd64.tgz .
[/tmp] # cd -
/home/dpitts/projects/learning-cockroach
[~/projects/learning-cockroach] # cat ./start_cluster_3nodes_tpcc.sh
#!/bin/bash

pkill -9 cockroach
# https://www.cockroachlabs.com/docs/v20.2/start-a-local-cluster
# node1

# remove previous cockroach setup 
rm -rf node*
mkdir -p node1
mkdir -p node2
mkdir -p node3

cockroach start --insecure --background --store=node1 --listen-addr=localhost:26257 --http-addr=localhost:8080 --join=localhost:26257,localhost:26258,localhost:26259
cockroach start --insecure --background --store=node2 --listen-addr=localhost:26258 --http-addr=localhost:8081 --join=localhost:26257,localhost:26258,localhost:26259
cockroach start --insecure --background --store=node3 --listen-addr=localhost:26259 --http-addr=localhost:8082 --join=localhost:26257,localhost:26258,localhost:26259
cockroach init --insecure --host=localhost:26257

cockroach sql --execute="SET CLUSTER SETTING server.time_until_store_dead = '1m15s';" --insecure

#cockroach workload init movr
cockroach workload fixtures import tpcc --warehouses=10 'postgresql://root@localhost:26257?sslmode=disable'

sleep 1; cockroach node status --host localhost:26257 --insecure
[~/projects/learning-cockroach] # cat restart_cluster_3nodes.sh 
#!/bin/bash

cockroach node status --host localhost:26257 --insecure
cockroach start --insecure --background --store=node1 --listen-addr=localhost:26257 --http-addr=localhost:8080 --join=localhost:26257,localhost:26258,localhost:26259
sleep 1; cockroach node status --host localhost:26257 --insecure
cockroach start --insecure --background --store=node2 --listen-addr=localhost:26258 --http-addr=localhost:8081 --join=localhost:26257,localhost:26258,localhost:26259
sleep 1; cockroach node status --host localhost:26257 --insecure
cockroach start --insecure --background --store=node3 --listen-addr=localhost:26259 --http-addr=localhost:8082 --join=localhost:26257,localhost:26258,localhost:26259
sleep 1; cockroach node status --host localhost:26257 --insecure
[~/projects/learning-cockroach] # ./restart_cluster_3nodes.sh
ERROR: server is not accepting clients
SQLSTATE: 57P01
Failed running "node status"
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
* ERROR: ERROR: could not cleanup temporary directories from record file: could not lock temporary directory /home/dpitts/projects/learning-cockroach/node1/cockroach-temp416397846, may still be in use: IO error: While lock file: /home/dpitts/projects/learning-cockroach/node1/cockroach-temp416397846/TEMP_DIR.LOCK: Resource temporarily unavailable
*
ERROR: could not cleanup temporary directories from record file: could not lock temporary directory /home/dpitts/projects/learning-cockroach/node1/cockroach-temp416397846, may still be in use: IO error: While lock file: /home/dpitts/projects/learning-cockroach/node1/cockroach-temp416397846/TEMP_DIR.LOCK: Resource temporarily unavailable
Failed running "start"
E210811 19:27:39.341047 1 cli/error.go:398  ERROR: exit status 1
ERROR: exit status 1
Failed running "start"
ERROR: server is not accepting clients
SQLSTATE: 57P01
Failed running "node status"
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
ERROR: server is not accepting clients
SQLSTATE: 57P01
Failed running "node status"
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
ERROR: server is not accepting clients
SQLSTATE: 57P01
Failed running "node status"
[~/projects/learning-cockroach] # server drained and shutdown completed

[~/projects/learning-cockroach] # cat ./restart_cluster_3nodes.sh
#!/bin/bash

cockroach node status --host localhost:26257 --insecure
cockroach start --insecure --background --store=node1 --listen-addr=localhost:26257 --http-addr=localhost:8080 --join=localhost:26257,localhost:26258,localhost:26259
sleep 1; cockroach node status --host localhost:26257 --insecure
cockroach start --insecure --background --store=node2 --listen-addr=localhost:26258 --http-addr=localhost:8081 --join=localhost:26257,localhost:26258,localhost:26259
sleep 1; cockroach node status --host localhost:26257 --insecure
cockroach start --insecure --background --store=node3 --listen-addr=localhost:26259 --http-addr=localhost:8082 --join=localhost:26257,localhost:26258,localhost:26259
sleep 1; cockroach node status --host localhost:26257 --insecure
[~/projects/learning-cockroach] # cockroach node status --host localhost:26257 --insecure
ERROR: cannot dial server.
Is the server running?
If the server is running, check --host client-side and --advertise server-side.

dial tcp 127.0.0.1:26257: connect: connection refused
Failed running "node status"
[~/projects/learning-cockroach] # cd /tmp
[/tmp] # tar -xzf cockroach-v21.1.6.linux-amd64.tgz
[/tmp] # i="$(which cockroach)"; mv "$i" "$i"_old
mv: cannot move '/usr/local/bin/cockroach' to '/usr/local/bin/cockroach_old': Permission denied
[/tmp] # suudo i="$(which cockroach)"; mv "$i" "$i"_old
No command 'suudo' found, did you mean:
 Command 'sudo' from package 'sudo-ldap' (universe)
 Command 'sudo' from package 'sudo' (main)
suudo: command not found
mv: cannot move '/usr/local/bin/cockroach' to '/usr/local/bin/cockroach_old': Permission denied
[/tmp] # id
uid=1001(dpitts) gid=1001(dpitts) groups=1001(dpitts),4(adm),27(sudo),113(lpadmin),128(sambashare)
[/tmp] # sudo mv ^C
[/tmp] # sudo mv /usr/local/bin/cockroach /usr/local/bin/cockroach.old
[sudo] password for dpitts: 
[/tmp] # cp -i cockroach-v21.1.6.linux-amd64/cockroach /usr/local/bin/cockroach
cp: cannot create regular file '/usr/local/bin/cockroach': Permission denied
[/tmp] # sudo cp -i cockroach-v21.1.6.linux-amd64/cockroach /usr/local/bin/cockroach
[/tmp] # cockroach node status --host localhost:26257 --insecure
ERROR: cannot dial server.
Is the server running?
If the server is running, check --host client-side and --advertise server-side.

dial tcp 127.0.0.1:26257: connect: connection refused
Failed running "node status"
[/tmp] # cockroach start --insecure --background --store=node1 --listen-addr=localhost:26257 --http-addr=localhost:8080 --join=localhost:26257,localhost:26258,localhost:26259
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
* - https://go.crdb.dev/issue-v/53404/v21.1
* - https://www.cockroachlabs.com/docs/v21.1/secure-a-cluster.html
*
*
* INFO: initial startup completed.
* Node will now attempt to join a running cluster, or wait for `cockroach init`.
* Client connections will be accepted after this completes successfully.
* Check the log file(s) for progress. 
*
[/tmp] # sleep 1; cockroach node status --host localhost:26257 --insecure

  id |     address     |   sql_address   |  build  |         started_at         |         updated_at         | locality | is_available | is_live
-----+-----------------+-----------------+---------+----------------------------+----------------------------+----------+--------------+----------
   1 | localhost:26257 | localhost:26257 | v20.2.7 | 2021-08-08 20:20:38.096553 | 2021-08-11 19:27:56.163778 |          | false        | false
   2 | localhost:26258 | localhost:26258 | v20.2.7 | 2021-08-11 19:27:41.118193 | 2021-08-11 19:35:11.189585 |          | true         | true
   3 | localhost:26259 | localhost:26259 | v20.2.7 | 2021-08-11 19:27:43.102649 | 2021-08-11 19:35:13.195061 |          | true         | true
   4 | localhost:26257 | localhost:26257 | v21.1.6 | 2021-08-11 19:35:12.268839 | 2021-08-11 19:35:12.322236 |          | true         | true
(4 rows)
[/tmp] # cockroach start --insecure --background --store=node2 --listen-addr=localhost:26258 --http-addr=localhost:8081 --join=localhost:26257,localhost:26258,localhost:26259
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
* - https://go.crdb.dev/issue-v/53404/v21.1
* - https://www.cockroachlabs.com/docs/v21.1/secure-a-cluster.html
*
*
* ERROR: ERROR: cannot dial server.
* Is the server running?
* If the server is running, check --host client-side and --advertise server-side.
* 
* cockroach server exited with error: consider changing the port via --http-addr: listen tcp 127.0.0.1:8081: bind: address already in use
*
ERROR: cannot dial server.
Is the server running?
If the server is running, check --host client-side and --advertise server-side.

cockroach server exited with error: consider changing the port via --http-addr: listen tcp 127.0.0.1:8081: bind: address already in use
Failed running "start"
E210811 19:35:13.862405 1 1@cli/error.go:399  [-] 1  ERROR: exit status 1
ERROR: exit status 1
Failed running "start"
[/tmp] # sleep 1; cockroach node status --host localhost:26257 --insecure
  id |     address     |   sql_address   |  build  |         started_at         |         updated_at         | locality | is_available | is_live
-----+-----------------+-----------------+---------+----------------------------+----------------------------+----------+--------------+----------
   1 | localhost:26257 | localhost:26257 | v20.2.7 | 2021-08-08 20:20:38.096553 | 2021-08-11 19:27:56.163778 |          | false        | false
   2 | localhost:26258 | localhost:26258 | v20.2.7 | 2021-08-11 19:27:41.118193 | 2021-08-11 19:35:11.189585 |          | true         | true
   3 | localhost:26259 | localhost:26259 | v20.2.7 | 2021-08-11 19:27:43.102649 | 2021-08-11 19:35:13.195061 |          | true         | true
   4 | localhost:26257 | localhost:26257 | v21.1.6 | 2021-08-11 19:35:12.268839 | 2021-08-11 19:35:12.322236 |          | true         | true
(4 rows)
[/tmp] # cockroach start --insecure --background --store=node3 --listen-addr=localhost:26259 --http-addr=localhost:8082 --join=localhost:26257,localhost:26258,localhost:26259
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
* - https://go.crdb.dev/issue-v/53404/v21.1
* - https://www.cockroachlabs.com/docs/v21.1/secure-a-cluster.html
*
*
* ERROR: ERROR: cannot dial server.
* Is the server running?
* If the server is running, check --host client-side and --advertise server-side.
* 
* cockroach server exited with error: consider changing the port via --http-addr: listen tcp 127.0.0.1:8082: bind: address already in use
*
ERROR: cannot dial server.
Is the server running?
If the server is running, check --host client-side and --advertise server-side.

cockroach server exited with error: consider changing the port via --http-addr: listen tcp 127.0.0.1:8082: bind: address already in use
Failed running "start"
E210811 19:35:15.377316 1 1@cli/error.go:399  [-] 1  ERROR: exit status 1
ERROR: exit status 1
Failed running "start"
[/tmp] # sleep 1; cockroach node status --host localhost:26257 --insecure
  id |     address     |   sql_address   |  build  |         started_at         |         updated_at         | locality | is_available | is_live
-----+-----------------+-----------------+---------+----------------------------+----------------------------+----------+--------------+----------
   1 | localhost:26257 | localhost:26257 | v20.2.7 | 2021-08-08 20:20:38.096553 | 2021-08-11 19:27:56.163778 |          | false        | false
   2 | localhost:26258 | localhost:26258 | v20.2.7 | 2021-08-11 19:27:41.118193 | 2021-08-11 19:35:15.677574 |          | true         | true
   3 | localhost:26259 | localhost:26259 | v20.2.7 | 2021-08-11 19:27:43.102649 | 2021-08-11 19:35:13.195061 |          | true         | true
   4 | localhost:26257 | localhost:26257 | v21.1.6 | 2021-08-11 19:35:12.268839 | 2021-08-11 19:35:12.322236 |          | true         | true
(4 rows)
[/tmp] # cockroach sql --insecure --host=localhost:26257 --execute="select 1"
  ?column?
------------
         1
(1 row)

Time: 1ms

[/tmp] # cockroach sql --insecure --host=localhost:26257 --execute="RESET CLUSTER SETTING cluster.preserve_downgrade_option;"
SET CLUSTER SETTING

Time: 58ms

[/tmp] # sleep 1; cockroach node status --host localhost:26257 --insecure
  id |     address     |   sql_address   |  build  |         started_at         |         updated_at         | locality | is_available | is_live
-----+-----------------+-----------------+---------+----------------------------+----------------------------+----------+--------------+----------
   1 | localhost:26257 | localhost:26257 | v20.2.7 | 2021-08-08 20:20:38.096553 | 2021-08-11 19:27:56.163778 |          | false        | false
   2 | localhost:26258 | localhost:26258 | v20.2.7 | 2021-08-11 19:27:41.118193 | 2021-08-11 19:38:42.69102  |          | true         | true
   3 | localhost:26259 | localhost:26259 | v20.2.7 | 2021-08-11 19:27:43.102649 | 2021-08-11 19:38:40.2053   |          | true         | true
   4 | localhost:26257 | localhost:26257 | v21.1.6 | 2021-08-11 19:35:12.268839 | 2021-08-11 19:38:39.299438 |          | true         | true
(4 rows)
(failed reverse-i-search)`pk': <div class="lang-list" style="dis^Cay:none;"><ul>
[/tmp] # pkill cockroach
initiating graceful shutdown of server
initiating graceful shutdown of server
[/tmp] # initiating graceful shutdown of server
server drained and shutdown completed
server drained and shutdown completed

[/tmp] # cockroach start --insecure --background --store=node1 --listen-addr=localhost:26257 --http-addr=localhost:8080 --join=localhost:26257,localhost:26258,localhost:26259
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
* - https://go.crdb.dev/issue-v/53404/v21.1
* - https://www.cockroachlabs.com/docs/v21.1/secure-a-cluster.html
*
[/tmp] # cockroach start --insecure --background --store=node2 --listen-addr=localhost:26258 --http-addr=localhost:8081 --join=localhost:26257,localhost:26258,localhost:26259
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
* - https://go.crdb.dev/issue-v/53404/v21.1
* - https://www.cockroachlabs.com/docs/v21.1/secure-a-cluster.html
*
*
* INFO: initial startup completed.
* Node will now attempt to join a running cluster, or wait for `cockroach init`.
* Client connections will be accepted after this completes successfully.
* Check the log file(s) for progress. 
*
[/tmp] # cockroach start --insecure --background --store=node3 --listen-addr=localhost:26259 --http-addr=localhost:8082 --join=localhost:26257,localhost:26258,localhost:26259
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
* - https://go.crdb.dev/issue-v/53404/v21.1
* - https://www.cockroachlabs.com/docs/v21.1/secure-a-cluster.html
*
*
* INFO: initial startup completed.
* Node will now attempt to join a running cluster, or wait for `cockroach init`.
* Client connections will be accepted after this completes successfully.
* Check the log file(s) for progress. 
*
[/tmp] # sleep 1; cockroach node status --host localhost:26257 --insecure
  id |     address     |   sql_address   |  build  |         started_at         |         updated_at         | locality | is_available | is_live
-----+-----------------+-----------------+---------+----------------------------+----------------------------+----------+--------------+----------
   1 | localhost:26257 | localhost:26257 | v20.2.7 | 2021-08-08 20:20:38.096553 | 2021-08-11 19:39:53.069063 |          | false        | false
   2 | localhost:26258 | localhost:26258 | v20.2.7 | 2021-08-11 19:27:41.118193 | 2021-08-11 19:39:53.06907  |          | false        | false
   3 | localhost:26259 | localhost:26259 | v20.2.7 | 2021-08-11 19:27:43.102649 | 2021-08-11 19:39:53.069072 |          | false        | false
   4 | localhost:26257 | localhost:26257 | v21.1.6 | 2021-08-11 19:39:50.925301 | 2021-08-11 19:39:53.069075 |          | false        | true
(4 rows)
```