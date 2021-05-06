Stopping and Removing a Local CockroachDB Cluster 


The brutual way is via pkill
```
[c7cockroach:vagrant:/vagrant] # ps -ef|grep cockroach
vagrant   1679     1 14 May03 pts/0    10:33:41 cockroach start --insecure --store=node1 --listen-addr=localhost:26257 --http-addr=localhost:8080 --join=localhost:26257,localhost:26258,localhost:26259
vagrant   1699     1 15 May03 pts/0    10:49:46 cockroach start --insecure --store=node2 --listen-addr=localhost:26258 --http-addr=localhost:8081 --join=localhost:26257,localhost:26258,localhost:26259
vagrant   1719     1 15 May03 pts/0    10:44:06 cockroach start --insecure --store=node3 --listen-addr=localhost:26259 --http-addr=localhost:8082 --join=localhost:26257,localhost:26258,localhost:26259
vagrant   1776  1753  0 May03 pts/1    00:09:26 cockroach sql --insecure --host=localhost:26257
vagrant   4500  1631  0 20:46 pts/0    00:00:00 grep --color=auto cockroach
[c7cockroach:vagrant:/vagrant] # date
Thu May  6 20:46:44 UTC 2021
[c7cockroach:vagrant:/vagrant] # pkill -9 cockroach
[c7cockroach:vagrant:/vagrant] # ps -ef|grep cockroach
vagrant   4505  1631  0 20:47 pts/0    00:00:00 grep --color=auto cockroach
[c7cockroach:vagrant:/vagrant] # 
```
interesting the load for this vagrant VM with almost zero usage was high before the pkill
```
[c7cockroach:vagrant:/vagrant] # uptime
 20:48:05 up 2 days, 23:09,  2 users,  load average: 2.61, 5.61, 6.45
[c7cockroach:vagrant:/vagrant] # uptime
 20:48:48 up 2 days, 23:10,  2 users,  load average: 1.23, 4.82, 6.14
```

Next as per the course notes, the datafiles are there

> The previously active nodes will leave behind data folders which will need to be deleted before starting a new cluster. By default the folders will have a name like cockroach-data and may have a number if multiple nodes were running. Warning: by trashing these folders, any data stored in the cluster will be permanently deleted.


Here is the startup script used

```
[c7cockroach:vagrant:/vagrant] # cat cockroachdb_start_cluster.sh 
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
```

and here is the three node1/2/3 folders created with data and log files

```
[c7cockroach:vagrant:/vagrant] # ls node*
node1:
001108.sst  001115.sst  001124.sst  001129.log  001134.sst  001139.log  001144.sst  001149.sst  001154.sst  001159.sst  LOCK                     cockroach.advertise-addr      logs
001109.sst  001116.sst  001125.sst  001130.sst  001135.sst  001140.sst  001145.sst  001150.sst  001155.sst  001160.sst  MANIFEST-000001          cockroach.advertise-sql-addr  temp-dirs-record.txt
001110.log  001117.sst  001126.sst  001131.sst  001136.sst  001141.sst  001146.log  001151.sst  001156.sst  001161.sst  OPTIONS-000003           cockroach.http-addr
001111.sst  001118.log  001127.sst  001132.sst  001137.sst  001142.sst  001147.sst  001152.sst  001157.sst  001162.sst  auxiliary                cockroach.listen-addr
001112.sst  001119.sst  001128.sst  001133.sst  001138.sst  001143.sst  001148.sst  001153.sst  001158.log  CURRENT     cockroach-temp460509102  cockroach.sql-addr

node2:
001509.log  001540.sst  001544.log  001553.sst  001557.sst  001561.sst  001565.sst  001569.sst  001573.sst  LOCK             cockroach-temp171391495       cockroach.listen-addr
001520.log  001541.sst  001545.sst  001554.sst  001558.sst  001562.sst  001566.sst  001570.log  001574.sst  MANIFEST-000001  cockroach.advertise-addr      cockroach.sql-addr
001533.log  001542.sst  001547.sst  001555.log  001559.sst  001563.sst  001567.sst  001571.sst  001575.sst  OPTIONS-000003   cockroach.advertise-sql-addr  logs
001539.sst  001543.sst  001552.sst  001556.sst  001560.sst  001564.sst  001568.sst  001572.sst  CURRENT     auxiliary        cockroach.http-addr           temp-dirs-record.txt

node3:
001546.log  001567.sst  001576.sst  001581.log  001586.sst  001591.sst  001596.sst  001601.sst  001606.log  CURRENT          cockroach-temp196440537       cockroach.sql-addr
001556.log  001568.log  001577.sst  001582.sst  001587.sst  001592.log  001597.sst  001602.sst  001607.sst  LOCK             cockroach.advertise-addr      logs
001564.sst  001571.sst  001578.sst  001583.sst  001588.sst  001593.sst  001598.sst  001603.sst  001608.sst  MANIFEST-000001  cockroach.advertise-sql-addr  temp-dirs-record.txt
001565.sst  001574.sst  001579.sst  001584.sst  001589.sst  001594.sst  001599.sst  001604.sst  001609.sst  OPTIONS-000003   cockroach.http-addr
001566.sst  001575.sst  001580.sst  001585.sst  001590.sst  001595.sst  001600.sst  001605.sst  001610.sst  auxiliary        cockroach.listen-addr
```
