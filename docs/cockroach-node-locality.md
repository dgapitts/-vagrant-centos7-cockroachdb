# cockroach node locality


As per the course
> When starting a node with a copper start command, you can use the locality flag to assign arbitrary key value pairs that described the location of the node.
This might include country region or availability zone.
While the choice of what keys and values you use are arbitrary, key value pairs should be sensible.
So if you're using a cloud provider, their region and zone names would make sense.
Regardless, they need to be ordered from most inclusive to lease inclusive.



and demoing this via a setup script

```
[~/projects/vagrant-centos7-cockroachdb] # cat start_cluster_9nodes_with_locality.sh 
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
```



notice the locality data in `cockroach node status` output

```
[~/projects/vagrant-centos7-cockroachdb] # cockroach node status --insecure
  id |     address     |   sql_address   |  build  |            started_at            |            updated_at            |           locality           | is_available | is_live
-----+-----------------+-----------------+---------+----------------------------------+----------------------------------+------------------------------+--------------+----------
   1 | localhost:26257 | localhost:26257 | v20.2.7 | 2021-05-19 17:35:47.583849+00:00 | 2021-05-19 17:37:31.188109+00:00 | country=us,region=us-east    | true         | true
   2 | localhost:26260 | localhost:26260 | v20.2.7 | 2021-05-19 17:35:49.124862+00:00 | 2021-05-19 17:37:32.71549+00:00  | country=us,region=us-central | true         | true
   3 | localhost:26261 | localhost:26261 | v20.2.7 | 2021-05-19 17:35:50.165497+00:00 | 2021-05-19 17:37:29.219162+00:00 | country=us,region=us-central | true         | true
   4 | localhost:26262 | localhost:26262 | v20.2.7 | 2021-05-19 17:35:51.415893+00:00 | 2021-05-19 17:37:30.537638+00:00 | country=us,region=us-central | true         | true
   5 | localhost:26258 | localhost:26258 | v20.2.7 | 2021-05-19 17:35:48.030523+00:00 | 2021-05-19 17:37:31.60834+00:00  | country=us,region=us-east    | true         | true
   6 | localhost:26259 | localhost:26259 | v20.2.7 | 2021-05-19 17:35:48.490635+00:00 | 2021-05-19 17:37:32.048458+00:00 | country=us,region=us-east    | true         | true
   7 | localhost:26265 | localhost:26265 | v20.2.7 | 2021-05-19 17:35:53.950994+00:00 | 2021-05-19 17:37:33.199341+00:00 | country=us,region=us-west    | true         | true
   8 | localhost:26263 | localhost:26263 | v20.2.7 | 2021-05-19 17:35:54.01352+00:00  | 2021-05-19 17:37:28.754486+00:00 | country=us,region=us-west    | true         | true
   9 | localhost:26264 | localhost:26264 | v20.2.7 | 2021-05-19 17:35:54.074946+00:00 | 2021-05-19 17:37:28.742873+00:00 | country=us,region=us-west    | true         | true


```


getting back to the course
> Now that we know the users table has been generated correctly, I'll use the show ranges SQL statement to find what nodes the tables ranges are on.
The show ranges statement returns information about the range, the nodes the replicas are on, and the replica localities.
In this example, we can see that there's one replica in US East, one in US Central and one in US West.


and we can see the RANGES for the TABLE movr.users: 


```
root@localhost:26257/defaultdb> SHOW RANGES FROM TABLE movr.users;
                                     start_key                                     |                                     end_key                                      | range_id | range_size_mb | lease_holder |    lease_holder_locality     | replicas |                                    replica_localities
-----------------------------------------------------------------------------------+----------------------------------------------------------------------------------+----------+---------------+--------------+------------------------------+----------+-------------------------------------------------------------------------------------------
  NULL                                                                             | /"amsterdam"/"\xb333333@\x00\x80\x00\x00\x00\x00\x00\x00#"                       |       36 |      0.000116 |            8 | country=us,region=us-west    | {4,5,8}  | {"country=us,region=us-central","country=us,region=us-east","country=us,region=us-west"}
  /"amsterdam"/"\xb333333@\x00\x80\x00\x00\x00\x00\x00\x00#"                       | /"boston"/"333333D\x00\x80\x00\x00\x00\x00\x00\x00\n"                            |       44 |      0.000886 |            6 | country=us,region=us-east    | {2,6,8}  | {"country=us,region=us-central","country=us,region=us-east","country=us,region=us-west"}
  /"boston"/"333333D\x00\x80\x00\x00\x00\x00\x00\x00\n"                            | /"los angeles"/"\x99\x99\x99\x99\x99\x99H\x00\x80\x00\x00\x00\x00\x00\x00\x1e"   |       43 |       0.00046 |            5 | country=us,region=us-east    | {3,5,7}  | {"country=us,region=us-central","country=us,region=us-east","country=us,region=us-west"}
  /"los angeles"/"\x99\x99\x99\x99\x99\x99H\x00\x80\x00\x00\x00\x00\x00\x00\x1e"   | /"new york"/"\x19\x99\x99\x99\x99\x99J\x00\x80\x00\x00\x00\x00\x00\x00\x05"      |       42 |      0.001015 |            9 | country=us,region=us-west    | {3,6,9}  | {"country=us,region=us-central","country=us,region=us-east","country=us,region=us-west"}
  /"new york"/"\x19\x99\x99\x99\x99\x99J\x00\x80\x00\x00\x00\x00\x00\x00\x05"      | /"paris"/"\xcc\xcc\xcc\xcc\xcc\xcc@\x00\x80\x00\x00\x00\x00\x00\x00("            |       68 |      0.000214 |            3 | country=us,region=us-central | {3,5,8}  | {"country=us,region=us-central","country=us,region=us-east","country=us,region=us-west"}
  /"paris"/"\xcc\xcc\xcc\xcc\xcc\xcc@\x00\x80\x00\x00\x00\x00\x00\x00("            | /"san francisco"/"\x80\x00\x00\x00\x00\x00@\x00\x80\x00\x00\x00\x00\x00\x00\x19" |       41 |      0.001299 |            7 | country=us,region=us-west    | {1,3,7}  | {"country=us,region=us-east","country=us,region=us-central","country=us,region=us-west"}
  /"san francisco"/"\x80\x00\x00\x00\x00\x00@\x00\x80\x00\x00\x00\x00\x00\x00\x19" | /"seattle"/"ffffffH\x00\x80\x00\x00\x00\x00\x00\x00\x14"                         |       57 |      0.000669 |            3 | country=us,region=us-central | {3,6,9}  | {"country=us,region=us-central","country=us,region=us-east","country=us,region=us-west"}
  /"seattle"/"ffffffH\x00\x80\x00\x00\x00\x00\x00\x00\x14"                         | /"washington dc"/"L\xcc\xcc\xcc\xcc\xccL\x00\x80\x00\x00\x00\x00\x00\x00\x0f"    |       56 |      0.000671 |            3 | country=us,region=us-central | {1,3,8}  | {"country=us,region=us-east","country=us,region=us-central","country=us,region=us-west"}
  /"washington dc"/"L\xcc\xcc\xcc\xcc\xccL\x00\x80\x00\x00\x00\x00\x00\x00\x0f"    | NULL                                                                             |       66 |      0.000231 |            6 | country=us,region=us-east    | {2,6,8}  | {"country=us,region=us-central","country=us,region=us-east","country=us,region=us-west"}
(9 rows)

Time: 37ms total (execution 37ms / network 0ms
```

we can also check the LOCALITY of the node we have a connection to

```
root@localhost:26257/defaultdb> SHOW LOCALITY;
          locality
-----------------------------
  country=us,region=us-east
(1 row)

Time: 2ms total (execution 1ms / network 0ms)
```

