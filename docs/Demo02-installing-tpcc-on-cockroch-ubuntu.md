# Demo02 - installing tpcc on cockroch ubuntu - went smoothly


## Background - macair load issues

As per [Demo01 - installing tpcc on cockroch - macair load issues](docs/Demo01-installing-tpcc-on-cockroch-macair-load-issues.md) 

> I'm going to switch to a spare ubuntu machine which more disc space and more CPUs.

well as per the metrics below, on my old ubuntu CPU laptop, but still more CPU and disc space:
```
[~/projects/learning-cockroach] # cat /proc/cpuinfo | grep '^processor\|^model name'
processor	: 0
model name	: Intel(R) Core(TM) i3-6100H CPU @ 2.70GHz
processor	: 1
model name	: Intel(R) Core(TM) i3-6100H CPU @ 2.70GHz
processor	: 2
model name	: Intel(R) Core(TM) i3-6100H CPU @ 2.70GHz
processor	: 3
model name	: Intel(R) Core(TM) i3-6100H CPU @ 2.70GHz
[~/projects/learning-cockroach] # df -h .
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda2       454G   63G  369G  15% /
```

The base setup went much smoother.

## New start_cluster_3nodes_tpcc.sh script - very smooth load data (compared to macair)


```
[~/projects/learning-cockroach] # ./start_cluster_3nodes_tpcc.sh 
*
* WARNING: ALL SECURITY CONTROLS HAVE BEEN DISABLED!
* 
...
*
Cluster successfully initialized
SET CLUSTER SETTING

Time: 42ms

I210808 20:20:38.804124 1 ccl/workloadccl/fixture.go:342  starting import of 9 tables
I210808 20:20:40.468274 68 ccl/workloadccl/fixture.go:472  imported 9.9 KiB in district table (100 rows, 0 index entries, took 1.630247392s, 0.01 MiB/s)
I210808 20:20:40.599191 67 ccl/workloadccl/fixture.go:472  imported 529 B in warehouse table (10 rows, 0 index entries, took 1.761949898s, 0.00 MiB/s)
I210808 20:20:40.885506 72 ccl/workloadccl/fixture.go:472  imported 1.1 MiB in new_order table (90000 rows, 0 index entries, took 2.04725833s, 0.55 MiB/s)
I210808 20:20:42.752208 73 ccl/workloadccl/fixture.go:472  imported 7.8 MiB in item table (100000 rows, 0 index entries, took 3.913543673s, 1.99 MiB/s)
I210808 20:20:49.971525 71 ccl/workloadccl/fixture.go:472  imported 15 MiB in order table (300000 rows, 300000 index entries, took 11.133927409s, 1.35 MiB/s)
I210808 20:21:01.180518 70 ccl/workloadccl/fixture.go:472  imported 22 MiB in history table (300000 rows, 0 index entries, took 22.338704003s, 0.96 MiB/s)
I210808 20:21:09.246606 69 ccl/workloadccl/fixture.go:472  imported 176 MiB in customer table (300000 rows, 300000 index entries, took 30.407894236s, 5.78 MiB/s)
I210808 20:21:11.727913 74 ccl/workloadccl/fixture.go:472  imported 306 MiB in stock table (1000000 rows, 0 index entries, took 32.888849429s, 9.30 MiB/s)
I210808 20:21:16.906810 75 ccl/workloadccl/fixture.go:472  imported 165 MiB in order_line table (3001222 rows, 0 index entries, took 38.069204364s, 4.33 MiB/s)
I210808 20:21:16.995389 1 ccl/workloadccl/fixture.go:351  imported 692 MiB bytes in 9 tables (took 38.190225232s, 18.12 MiB/s)
I210808 20:21:19.579459 1 ccl/workloadccl/cliccl/fixtures.go:355  fixture is restored; now running consistency checks (ctrl-c to abort)
I210808 20:21:19.626650 1 workload/tpcc/tpcc.go:384  check 3.3.2.1 took 47.149727ms
I210808 20:21:20.307407 1 workload/tpcc/tpcc.go:384  check 3.3.2.2 took 680.712322ms
I210808 20:21:20.424432 1 workload/tpcc/tpcc.go:384  check 3.3.2.3 took 116.995365ms
I210808 20:21:23.631986 1 workload/tpcc/tpcc.go:384  check 3.3.2.4 took 3.207366748s
I210808 20:21:24.197894 1 workload/tpcc/tpcc.go:384  check 3.3.2.5 took 565.880559ms
I210808 20:21:27.003576 1 workload/tpcc/tpcc.go:384  check 3.3.2.7 took 2.805651124s
I210808 20:21:27.394522 1 workload/tpcc/tpcc.go:384  check 3.3.2.8 took 390.919469ms
I210808 20:21:27.780802 1 workload/tpcc/tpcc.go:384  check 3.3.2.9 took 386.254403ms
  id |     address     |   sql_address   |  build  |            started_at            |            updated_at            | locality | is_available | is_live
-----+-----------------+-----------------+---------+----------------------------------+----------------------------------+----------+--------------+----------
   1 | localhost:26257 | localhost:26257 | v20.2.7 | 2021-08-08 20:20:38.096553+00:00 | 2021-08-08 20:21:27.630548+00:00 |          | true         | true
   2 | localhost:26258 | localhost:26258 | v20.2.7 | 2021-08-08 20:20:38.626632+00:00 | 2021-08-08 20:21:28.236307+00:00 |          | true         | true
   3 | localhost:26259 | localhost:26259 | v20.2.7 | 2021-08-08 20:20:38.917166+00:00 | 2021-08-08 20:21:28.501851+00:00 |          | true         | true
(3 rows)
[~/projects/learning-cockroach] # uptime
 22:21:40 up 46 days,  2:56,  3 users,  load average: 5,51, 2,79, 1,58
[~/projects/learning-cockroach] # for i in {1..10};do uptime;du -hs node*;sleep 120;done
 22:22:44 up 46 days,  2:57,  3 users,  load average: 3,11, 2,60, 1,59
690M	node1
618M	node2
618M	node3
 22:24:44 up 46 days,  2:59,  3 users,  load average: 1,67, 2,21, 1,57
761M	node1
618M	node2
618M	node3
 22:26:44 up 46 days,  3:01,  3 users,  load average: 2,24, 2,29, 1,68
761M	node1
618M	node2
618M	node3
 22:28:44 up 46 days,  3:03,  3 users,  load average: 2,63, 2,27, 1,73
761M	node1
618M	node2
618M	node3
 22:30:44 up 46 days,  3:05,  3 users,  load average: 1,66, 1,96, 1,68
621M	node1
618M	node2
618M	node3
 22:32:44 up 46 days,  3:07,  3 users,  load average: 0,89, 1,58, 1,57
621M	node1
618M	node2
618M	node3
 22:34:44 up 46 days,  3:09,  3 users,  load average: 1,08, 1,48, 1,54
621M	node1
619M	node2
619M	node3
```
