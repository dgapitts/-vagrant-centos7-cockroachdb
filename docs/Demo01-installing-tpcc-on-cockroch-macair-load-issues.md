# Demo01 - installing tpcc on cockroch - macair load issues

## Background - macair load issues

For the last couple of months, I've been running through the cockroach univerisity course on my macair, without issues.

I'm made some initial details of the load issues I hit today, also the database continued to grow after the initial setup, I'm wondering if this was rebalancing?

I'm going to switch to a spare ubuntu machine which more disc space and more CPUs.

```
~/projects/vagrant-centos7-cockroachdb $ sysctl -n machdep.cpu.brand_string
Intel(R) Core(TM) i5-4260U CPU @ 1.40GHz
```

## New start_cluster_3nodes_tpcc.sh script 


```
~/projects/vagrant-centos7-cockroachdb $ cat start_cluster_3nodes_tpcc.sh
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
~/projects/vagrant-centos7-cockroachdb $ diff start_cluster_3nodes_tpcc.sh start_cluster_3nodes.sh
7,8c7
< # remove previous cockroach setup
< rm -rf node*
---
>
17d15
<
21,22d18
< cockroach workload fixtures import tpcc --warehouses=10 'postgresql://root@localhost:26257?sslmode=disable'
<
```


### Setup was slow (30mins) and heavs (very high load averagee)

This setup took a while
```
~/projects/vagrant-centos7-cockroachdb $ ./start_cluster_3nodes_tpcc.sh
*
* WARNING: ALL SECURITY CONTROLS HAVE BEEN DISABLED!
...
*
Cluster successfully initialized
SET CLUSTER SETTING

Time: 124ms

I210808 07:59:40.132166 1 ccl/workloadccl/fixture.go:342  [-] 1  starting import of 9 tables
I210808 07:59:46.625568 60 ccl/workloadccl/fixture.go:472  [-] 2  imported 7.8 MiB in item table (100000 rows, 0 index entries, took 6.329466s, 1.23 MiB/s)
I210808 07:59:52.514689 55 ccl/workloadccl/fixture.go:472  [-] 3  imported 9.9 KiB in district table (100 rows, 0 index entries, took 12.220224s, 0.00 MiB/s)
I210808 08:00:06.127037 54 ccl/workloadccl/fixture.go:472  [-] 4  imported 529 B in warehouse table (10 rows, 0 index entries, took 25.832834s, 0.00 MiB/s)
I210808 08:00:13.743009 58 ccl/workloadccl/fixture.go:472  [-] 5  imported 15 MiB in order table (300000 rows, 300000 index entries, took 33.435847s, 0.45 MiB/s)
I210808 08:00:17.763564 59 ccl/workloadccl/fixture.go:472  [-] 6  imported 1.1 MiB in new_order table (90000 rows, 0 index entries, took 37.467766s, 0.03 MiB/s)
I210808 08:00:23.142491 57 ccl/workloadccl/fixture.go:472  [-] 7  imported 22 MiB in history table (300000 rows, 0 index entries, took 42.847961s, 0.50 MiB/s)
I210808 08:08:16.209210 56 ccl/workloadccl/fixture.go:472  [-] 8  imported 58 MiB in customer table (100000 rows, 100000 index entries, took 8m35.900819s, 0.11 MiB/s)
I210808 08:13:57.325135 61 ccl/workloadccl/fixture.go:472  [-] 9  imported 306 MiB in stock table (1000000 rows, 0 index entries, took 14m17.029054s, 0.36 MiB/s)
I210808 08:15:51.300192 62 ccl/workloadccl/fixture.go:472  [-] 10  imported 55 MiB in order_line table (1000218 rows, 0 index entries, took 16m11.005538s, 0.06 MiB/s)
I210808 08:15:52.237887 1 ccl/workloadccl/fixture.go:351  [-] 11  imported 465 MiB bytes in 9 tables (took 16m11.96535s, 0.48 MiB/s)
I210808 08:16:21.403597 1 ccl/workloadccl/cliccl/fixtures.go:355  [-] 12  fixture is restored; now running consistency checks (ctrl-c to abort)
I210808 08:16:22.282896 1 workload/tpcc/tpcc.go:389  [-] 13  check 3.3.2.1 took 862.802ms
I210808 08:16:23.910452 1 workload/tpcc/tpcc.go:389  [-] 14  check 3.3.2.2 took 1.625305s
I210808 08:16:24.215497 1 workload/tpcc/tpcc.go:389  [-] 15  check 3.3.2.3 took 304.792ms
I210808 08:16:32.951348 1 workload/tpcc/tpcc.go:389  [-] 16  check 3.3.2.4 took 8.735652s
I210808 08:16:34.397992 1 workload/tpcc/tpcc.go:389  [-] 17  check 3.3.2.5 took 1.445942s
I210808 08:16:43.206793 1 workload/tpcc/tpcc.go:389  [-] 18  check 3.3.2.7 took 8.808536s
I210808 08:16:45.744919 1 workload/tpcc/tpcc.go:389  [-] 19  check 3.3.2.8 took 2.537907s
I210808 08:16:46.853084 1 workload/tpcc/tpcc.go:389  [-] 20  check 3.3.2.9 took 1.107882s
  id |     address     |   sql_address   |  build  |         started_at         |         updated_at         | locality | is_available | is_live
-----+-----------------+-----------------+---------+----------------------------+----------------------------+----------+--------------+----------
   1 | localhost:26257 | localhost:26257 | v21.1.1 | 2021-08-08 07:59:37.805867 | 2021-08-08 08:16:48.74335  |          | true         | true
   2 | localhost:26258 | localhost:26258 | v21.1.1 | 2021-08-08 07:59:39.014935 | 2021-08-08 08:16:49.785579 |          | true         | true
   3 | localhost:26259 | localhost:26259 | v21.1.1 | 2021-08-08 07:59:39.943572 | 2021-08-08 08:16:50.737502 |          | true         | true
(3 rows)
~/projects/vagrant-centos7-cockroachdb $ tail ./start_cluster_3nodes_tpcc.sh
cockroach start --insecure --background --store=node2 --listen-addr=localhost:26258 --http-addr=localhost:8081 --join=localhost:26257,localhost:26258,localhost:26259
cockroach start --insecure --background --store=node3 --listen-addr=localhost:26259 --http-addr=localhost:8082 --join=localhost:26257,localhost:26258,localhost:26259
cockroach init --insecure --host=localhost:26257

cockroach sql --execute="SET CLUSTER SETTING server.time_until_store_dead = '1m15s';" --insecure

#cockroach workload init movr
cockroach workload fixtures import tpcc --warehouses=10 'postgresql://root@localhost:26257?sslmode=disable'

sleep 1; cockroach node status --host localhost:26257 --insecure
~/projects/vagrant-centos7-cockroachdb $ cockroach node status --host localhost:26257 --insecure
  id |     address     |   sql_address   |  build  |         started_at         |         updated_at         | locality | is_available | is_live
-----+-----------------+-----------------+---------+----------------------------+----------------------------+----------+--------------+----------
   1 | localhost:26257 | localhost:26257 | v21.1.1 | 2021-08-08 07:59:37.805867 | 2021-08-08 08:21:54.4959   |          | true         | true
   2 | localhost:26258 | localhost:26258 | v21.1.1 | 2021-08-08 07:59:39.014935 | 2021-08-08 08:21:55.665544 |          | true         | true
   3 | localhost:26259 | localhost:26259 | v21.1.1 | 2021-08-08 07:59:39.943572 | 2021-08-08 08:21:56.625706 |          | true         | true
(3 rows)
```






## Monitoring disc usage and load - upto 2021-08-08 08:21utc (10:21cet) when initial setup completes

I the reason for the high IO load was largely around stuck IO (need to gather more evidence)

As above, at 2021-08-08 08:21utc (i.e. 10:21am cet - which is my laptop's tz ) the initial setup completes

```
~/projects/vagrant-centos7-cockroachdb $ for i in {1..10}; do uptime;du -hs node*;sleep 60;done
10:18  up 11 days, 12:40, 13 users, load averages: 12.70 24.35 26.92
324M	node1
293M	node2
271M	node3
10:19  up 11 days, 12:41, 13 users, load averages: 11.22 21.71 25.75
329M	node1
253M	node2
259M	node3
10:20  up 11 days, 12:42, 13 users, load averages: 8.04 18.92 24.43
333M	node1
258M	node2
264M	node3
10:21  up 11 days, 12:43, 13 users, load averages: 6.49 16.56 23.18
338M	node1
263M	node2
269M	node3
```

## Monitoring disc usage and load - after 2021-08-08 08:21utc (10:21cet) when initial setup completes

```
10:22  up 11 days, 12:44, 13 users, load averages: 6.15 14.60 21.99
343M	node1
268M	node2
274M	node3
10:23  up 11 days, 12:45, 13 users, load averages: 6.43 13.19 20.96
348M	node1
273M	node2
278M	node3
10:24  up 11 days, 12:46, 13 users, load averages: 6.92 12.11 20.03
353M	node1
278M	node2
283M	node3
10:25  up 11 days, 12:47, 13 users, load averages: 6.27 11.04 19.09
358M	node1
282M	node2
287M	node3
10:26  up 11 days, 12:48, 13 users, load averages: 7.39 10.48 18.33
363M	node1
287M	node2
292M	node3
10:27  up 11 days, 12:49, 13 users, load averages: 7.39 10.04 17.63
368M	node1
292M	node2
297M	node3
~/projects/vagrant-centos7-cockroachdb $ for i in {1..10}; do uptime;du -hs node*;sleep 60;done
10:45  up 11 days, 13:08, 13 users, load averages: 5.15 5.64 8.95
457M	node1
383M	node2
387M	node3
```


## Still seeing activity despite no csql client connections

As above the initial dataload completed around 8.21amUTC(10.21CET), however I'm still seeing high load and apparents updates (maybe reblancing afre initial dataload?)
```
~/projects/vagrant-centos7-cockroachdb $ cockroach node status --host localhost:26257 --insecure
  id |     address     |   sql_address   |  build  |         started_at         |         updated_at         | locality | is_available | is_live
-----+-----------------+-----------------+---------+----------------------------+----------------------------+----------+--------------+----------
   1 | localhost:26257 | localhost:26257 | v21.1.1 | 2021-08-08 07:59:37.805867 | 2021-08-08 08:46:46.424291 |          | true         | true
   2 | localhost:26258 | localhost:26258 | v21.1.1 | 2021-08-08 07:59:39.014935 | 2021-08-08 08:46:47.652877 |          | true         | true
   3 | localhost:26259 | localhost:26259 | v21.1.1 | 2021-08-08 07:59:39.943572 | 2021-08-08 08:46:48.567294 |          | true         | true
(3 rows)
```
and we high load averanges and disc usage (du) still increasing

```
~/projects/vagrant-centos7-cockroachdb $ for i in {1..10}; do uptime;du -hs node*;sleep 60;done
11:05  up 11 days, 13:28, 13 users, load averages: 4.89 5.70 6.57
549M	node1
470M	node2
480M	node3
...
```

I also capture some top detail

```
~/projects/vagrant-centos7-cockroachdb $ top -l 10 -i 2 -n 10 > cockroach_tpcc_postsetup.log
~/projects/vagrant-centos7-cockroachdb $ grep '^2021\|^Load\|^CPU\|PID\|cockroach' cockroach_tpcc_postsetup.log| head -40
2021/08/08 10:46:13
Load Avg: 5.49, 5.69, 8.91
CPU usage: 12.0% user, 30.66% sys, 57.33% idle
PID    COMMAND          %CPU TIME     #TH #WQ #PORTS MEM   PURG  CMPRS PGRP  PPID  STATE    BOOSTS %CPU_ME %CPU_OTHRS UID FAULTS COW  MSGSENT MSGRECV SYSBSD SYSMACH CSW  PAGEINS IDLEW POWER INSTRS CYCLES USER #MREGS RPRVT VPRVT VSIZE KPRVT KSHRD
2021/08/08 10:46:14
Load Avg: 5.49, 5.69, 8.91
CPU usage: 11.34% user, 22.26% sys, 66.39% idle
PID    COMMAND          %CPU TIME     #TH   #WQ #PORTS MEM    PURG   CMPRS PGRP  PPID  STATE    BOOSTS   %CPU_ME %CPU_OTHRS UID FAULTS    COW     MSGSENT    MSGRECV    SYSBSD    SYSMACH    CSW        PAGEINS IDLEW     POWER INSTRS    CYCLES    USER          #MREGS RPRVT VPRVT VSIZE KPRVT KSHRD
30727  cockroach        26.2 18:36.39 21    1   81     210M+  0B     83M-  30701 1     stuck    *0[1]    0.00000 0.00000    502 13623510+ 116703+ 10988      4440       31600507+ 7952       33151387+  66714+  1917440+  71.0  156063560 597141559 dave          N/A    N/A   N/A   N/A   N/A   N/A
30737  cockroach        24.6 20:11.11 20    1   80     166M+  0B     73M   30701 1     stuck    *0[1]    0.00000 0.00000    502 14406367+ 111281+ 11091      4469       30960426+ 8002       33188609+  86926   1434933+  52.4  147913501 562720863 dave          N/A    N/A   N/A   N/A   N/A   N/A
30710  cockroach        23.4 17:45.03 19/5  1   78     178M+  0B     66M   30701 1     running  *0[1]    0.00000 0.00000    502 14125078+ 125474  10852      4441       30786060+ 7948       32282965+  93409   1161775+  40.9  150529281 537889107 dave          N/A    N/A   N/A   N/A   N/A   N/A
2021/08/08 10:46:16
Load Avg: 5.77, 5.74, 8.91
CPU usage: 11.42% user, 19.58% sys, 68.99% idle
PID    COMMAND          %CPU TIME     #TH   #WQ #PORTS MEM    PURG   CMPRS PGRP  PPID  STATE    BOOSTS    %CPU_ME %CPU_OTHRS UID FAULTS    COW     MSGSENT    MSGRECV    SYSBSD    SYSMACH    CSW        PAGEINS IDLEW     POWER INSTRS    CYCLES    USER          #MREGS RPRVT VPRVT VSIZE KPRVT KSHRD
30727  cockroach        34.5 18:36.76 21/3  1   81     210M   0B     83M   30701 1     running  *0[1]     0.00000 0.00000    502 13623747+ 116703  10988      4440       31612754+ 7952       33164009+  66714   1918815+  99.1  115769950 511955553 dave          N/A    N/A   N/A   N/A   N/A   N/A
30737  cockroach        32.7 20:11.46 20    1   80     166M   0B     73M   30701 1     sleeping *0[1]     0.00000 0.00000    502 14406540+ 111281  11091      4469       30972787+ 8002       33201586+  86926   1435807+  73.8  117055769 488065447 dave          N/A    N/A   N/A   N/A   N/A   N/A
30710  cockroach        30.1 17:45.35 19    1   78     178M   0B     66M   30701 1     sleeping *0[1]     0.00000 0.00000    502 14125481+ 125476+ 10852      4441       30798929+ 7948       32295777+  93409   1162469+  62.7  123576278 448045715 dave          N/A    N/A   N/A   N/A   N/A   N/A
2021/08/08 10:46:17
Load Avg: 5.77, 5.74, 8.91
CPU usage: 13.3% user, 22.27% sys, 64.69% idle
PID    COMMAND          %CPU TIME     #TH   #WQ #PORTS MEM    PURG   CMPRS PGRP  PPID  STATE    BOOSTS    %CPU_ME %CPU_OTHRS UID FAULTS    COW     MSGSENT    MSGRECV    SYSBSD    SYSMACH    CSW        PAGEINS IDLEW     POWER INSTRS    CYCLES    USER          #MREGS RPRVT VPRVT VSIZE KPRVT KSHRD
30737  cockroach        38.2 20:12.26 20    1   80     167M+  0B     73M-  30701 1     stuck    *0[1]     0.00000 0.00000    502 14411863+ 111281  11093+     4470+      31002126+ 8004+      33229392+  86926   1437459+  76.7  359860668 657524580 dave          N/A    N/A   N/A   N/A   N/A   N/A
30727  cockroach        31.4 18:37.54 21    1   81     211M+  0B     82M   30701 1     stuck    *0[1]     0.00000 0.00000    502 13628771+ 116704  10990      4441       31642109+ 7954       33192085+  66714   1921423+  86.3  138717467 483917960 dave          N/A    N/A   N/A   N/A   N/A   N/A
30710  cockroach        29.8 17:46.08 19    1   78     179M+  0B     66M   30701 1     stuck    *0[1]     0.00000 0.00000    502 14131104+ 125476  10854      4442       30827371+ 7950       32323371+  93409   1163850+  63.2  166619442 471629046 dave          N/A    N/A   N/A   N/A   N/A   N/A
2021/08/08 10:46:19
Load Avg: 5.77, 5.74, 8.91
CPU usage: 9.79% user, 19.58% sys, 70.62% idle
PID    COMMAND          %CPU TIME     #TH   #WQ #PORTS MEM    PURG   CMPRS PGRP  PPID  STATE    BOOSTS    %CPU_ME %CPU_OTHRS UID FAULTS    COW     MSGSENT    MSGRECV    SYSBSD    SYSMACH    CSW        PAGEINS IDLEW     POWER INSTRS    CYCLES    USER          #MREGS RPRVT VPRVT VSIZE KPRVT KSHRD
30727  cockroach        29.6 18:37.89 21/2  1   81     211M+  0B     82M   30701 1     running  *0[1]     0.00000 0.00000    502 13629598+ 116704  10990      4441       31655581+ 7954       33204464+  66714   1922810+  87.3  136589800 517825815 dave          N/A    N/A   N/A   N/A   N/A   N/A
30737  cockroach        27.6 20:12.59 20    1   80     167M   0B     73M   30701 1     sleeping *0[1]     0.00000 0.00000    502 14411992+ 111281  11093      4470       31016137+ 8004       33242363+  86926   1438434+  68.2  126691040 480460268 dave          N/A    N/A   N/A   N/A   N/A   N/A
30710  cockroach        26.7 17:46.40 19    1   78     179M   0B     66M   30701 1     stuck    *0[1]     0.00000 0.00000    502 14131286+ 125476  10854      4442       30841881+ 7950       32336252+  93409   1164537+  55.3  125414536 460684122 dave          N/A    N/A   N/A   N/A   N/A   N/A
2021/08/08 10:46:20
```


