## geo-partitioning basic demo script -  enterprise-only feature

As the name implies geo-partitioning is partition the ranges by the [locality](cockroach-node-locality.md) field e.g. here is a simple demo script

```
[~/projects/vagrant-centos7-cockroachdb] # cat geo-partitioning.sql
SHOW RANGES FROM TABLE movr.vehicles;

ALTER TABLE movr.vehicles
PARTITION BY LIST (city) (
    PARTITION new_york VALUES IN ('new york'),
    PARTITION boston VALUES IN ('boston'),
    PARTITION washington_dc VALUES IN ('washington dc'),
    PARTITION seattle VALUES IN ('seattle'),
    PARTITION san_francisco VALUES IN ('san francisco'),
    PARTITION los_angeles VALUES IN ('los angeles')
);

ALTER PARTITION new_york OF TABLE movr.vehicles
CONFIGURE ZONE USING constraints='[+region=us-east]';

ALTER PARTITION boston OF TABLE movr.vehicles
CONFIGURE ZONE USING constraints='[+region=us-east]';

ALTER PARTITION washington_dc OF TABLE movr.vehicles
CONFIGURE ZONE USING constraints='[+region=us-central]';

ALTER PARTITION seattle OF TABLE movr.vehicles
CONFIGURE ZONE USING constraints='[+region=us-west]';

ALTER PARTITION san_francisco OF TABLE movr.vehicles
CONFIGURE ZONE USING constraints='[+region=us-west]';

ALTER PARTITION los_angeles OF TABLE movr.vehicles
CONFIGURE ZONE USING constraints='[+region=us-west]';

SELECT start_key, end_key, lease_holder_locality, replicas, replica_localities FROM [SHOW RANGES FROM TABLE movr.vehicles]
WHERE "start_key" NOT LIKE '%Prefix%' AND "end_key" NOT LIKE '%Prefix';
```

We can run the above script via cat ... | cockroach sql ... 

Unfortunately geo-partitioning is an enterprise feature 

```
[~/projects/vagrant-centos7-cockroachdb] # cat geo-partitioning.sql | cockroach sql --insecure --host=localhost:26257
                                    start_key                                    |                                    end_key                                     | range_id | range_size_mb | lease_holder |    lease_holder_locality     | replicas |                                    replica_localities
---------------------------------------------------------------------------------+--------------------------------------------------------------------------------+----------+---------------+--------------+------------------------------+----------+-------------------------------------------------------------------------------------------
  NULL                                                                           | /"boston"/"\"\"\"\"\"\"B\x00\x80\x00\x00\x00\x00\x00\x00\x02"                  |       37 |      0.000305 |            6 | country=us,region=us-east    | {4,6,7}  | {"country=us,region=us-central","country=us,region=us-east","country=us,region=us-west"}
  /"boston"/"\"\"\"\"\"\"B\x00\x80\x00\x00\x00\x00\x00\x00\x02"                  | /"boston"/"333333D\x00\x80\x00\x00\x00\x00\x00\x00\x03"                        |       48 |      0.000144 |            8 | country=us,region=us-west    | {4,6,8}  | {"country=us,region=us-central","country=us,region=us-east","country=us,region=us-west"}
  /"boston"/"333333D\x00\x80\x00\x00\x00\x00\x00\x00\x03"                        | /"new york"/"\x11\x11\x11\x11\x11\x11A\x00\x80\x00\x00\x00\x00\x00\x00\x01"    |       47 |      0.000458 |            6 | country=us,region=us-east    | {2,6,8}  | {"country=us,region=us-central","country=us,region=us-east","country=us,region=us-west"}
  /"new york"/"\x11\x11\x11\x11\x11\x11A\x00\x80\x00\x00\x00\x00\x00\x00\x01"    | /"san francisco"/"wwwwwwH\x00\x80\x00\x00\x00\x00\x00\x00\a"                   |       46 |      0.000613 |            4 | country=us,region=us-central | {1,4,9}  | {"country=us,region=us-east","country=us,region=us-central","country=us,region=us-west"}
  /"san francisco"/"wwwwwwH\x00\x80\x00\x00\x00\x00\x00\x00\a"                   | /"san francisco"/"\x88\x88\x88\x88\x88\x88H\x00\x80\x00\x00\x00\x00\x00\x00\b" |       86 |       0.00016 |            1 | country=us,region=us-east    | {1,2,7}  | {"country=us,region=us-east","country=us,region=us-central","country=us,region=us-west"}
  /"san francisco"/"\x88\x88\x88\x88\x88\x88H\x00\x80\x00\x00\x00\x00\x00\x00\b" | /"seattle"/"UUUUUUD\x00\x80\x00\x00\x00\x00\x00\x00\x05"                       |       45 |      0.000149 |            8 | country=us,region=us-west    | {4,6,8}  | {"country=us,region=us-central","country=us,region=us-east","country=us,region=us-west"}
  /"seattle"/"UUUUUUD\x00\x80\x00\x00\x00\x00\x00\x00\x05"                       | /"seattle"/"ffffffH\x00\x80\x00\x00\x00\x00\x00\x00\x06"                       |       70 |      0.000153 |            2 | country=us,region=us-central | {2,6,7}  | {"country=us,region=us-central","country=us,region=us-east","country=us,region=us-west"}
  /"seattle"/"ffffffH\x00\x80\x00\x00\x00\x00\x00\x00\x06"                       | /"washington dc"/"DDDDDDD\x00\x80\x00\x00\x00\x00\x00\x00\x04"                 |       69 |      0.000142 |            5 | country=us,region=us-east    | {4,5,8}  | {"country=us,region=us-central","country=us,region=us-east","country=us,region=us-west"}
  /"washington dc"/"DDDDDDD\x00\x80\x00\x00\x00\x00\x00\x00\x04"                 | NULL                                                                           |       58 |      0.001448 |            6 | country=us,region=us-east    | {2,6,7}  | {"country=us,region=us-central","country=us,region=us-east","country=us,region=us-west"}
(9 rows)

Time: 28ms

ERROR: use of partitions requires an enterprise license. see https://cockroachlabs.com/pricing?cluster=ed09d809-da0c-4565-83a6-973a01a453a3 for details on how to enable enterprise features
SQLSTATE: XXC02
ERROR: use of partitions requires an enterprise license. see https://cockroachlabs.com/pricing?cluster=ed09d809-da0c-4565-83a6-973a01a453a3 for details on how to enable enterprise features
SQLSTATE: XXC02
Failed running "sql"
```

and I have not find an easy & free to even demo this (yet)