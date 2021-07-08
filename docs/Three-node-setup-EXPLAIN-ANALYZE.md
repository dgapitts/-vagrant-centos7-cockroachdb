## Example EXPLAIN ANALYZE queries on a Three node setup (still didn't parallelize for our small 10K datasets)


### Restarting cockroach (cockroach on the mac doesn’t seem to like being put into sleep mode)

```
~/projects/vagrant-centos7-cockroachdb $ ./restart_cluster_3nodes.sh
…
  id |     address     |   sql_address   |  build  |         started_at         |         updated_at         | locality | is_available | is_live
-----+-----------------+-----------------+---------+----------------------------+----------------------------+----------+--------------+----------
   1 | localhost:26257 | localhost:26257 | v21.1.1 | 2021-07-02 20:48:32.131948 | 2021-07-02 21:08:02.289138 |          | true         | true
   2 | localhost:26259 | localhost:26259 | v21.1.1 | 2021-07-02 20:49:02.624392 | 2021-07-02 21:08:01.252002 |          | true         | true
   3 | localhost:26258 | localhost:26258 | v21.1.1 | 2021-07-02 20:48:49.918956 | 2021-07-02 21:08:02.101024 |          | true         | true
(3 rows)
```



### Regular explain - single node plan

```
root@localhost:26257/movr> explain select min(battery) from vehicles;
                                          info
----------------------------------------------------------------------------------------
  distribution: full
  vectorized: true

  • group (scalar)
  │ estimated row count: 1
  │
  └── • scan
        estimated row count: 9,998 (100% of the table; stats collected 12 minutes ago)
        table: vehicles@primary
        spans: FULL SCAN
(10 rows)

Time: 5ms total (execution 1ms / network 4ms)
```

### Training with explain analyse  

```
root@localhost:26257/movr> explain analyze select min(battery) from vehicles;
                                          info
----------------------------------------------------------------------------------------
  planning time: 309µs
  execution time: 8ms
  distribution: full
  vectorized: true
  rows read from KV: 9,998 (561 KiB)
  cumulative time spent in KV: 7ms
  maximum memory usage: 160 KiB
  network usage: 0 B (0 messages)

  • group (scalar)
  │ cluster nodes: n1
  │ actual row count: 1
  │ estimated row count: 1
  │
  └── • scan
        cluster nodes: n1
        actual row count: 9,998
        KV rows read: 9,998
        KV bytes read: 561 KiB
        estimated row count: 9,998 (100% of the table; stats collected 12 minutes ago)
        table: vehicles@primary
        spans: FULL SCAN
(22 rows)

Time: 16ms total (execution 9ms / network 7ms)
```

### Add a sort operation

```
root@localhost:26257/movr> explain select id,battery  from vehicles order by battery limit 10;
                                            info
--------------------------------------------------------------------------------------------
  distribution: full
  vectorized: true

  • limit
  │ estimated row count: 10
  │ count: 10
  │
  └── • sort
      │ estimated row count: 9,998
      │ order: +battery
      │
      └── • scan
            estimated row count: 9,998 (100% of the table; stats collected 28 minutes ago)
            table: vehicles@primary
            spans: FULL SCAN
(15 rows)

Time: 1ms total (execution 1ms / network 0ms)
```
and tracing this it only takes 20ms (on a single node)
```
root@localhost:26257/movr> explain analyze select id,battery  from vehicles order by battery limit 10;
                                            info
--------------------------------------------------------------------------------------------
  planning time: 196µs
  execution time: 18ms
  distribution: full
  vectorized: true
  rows read from KV: 9,998 (561 KiB)
  cumulative time spent in KV: 16ms
  maximum memory usage: 120 KiB
  network usage: 0 B (0 messages)

  • limit
  │ cluster nodes: n1
  │ actual row count: 10
  │ estimated row count: 10
  │ count: 10
  │
  └── • sort
      │ cluster nodes: n1
      │ actual row count: 10
      │ estimated row count: 9,998
      │ order: +battery
      │
      └── • scan
            cluster nodes: n1
            actual row count: 9,998
            KV rows read: 9,998
            KV bytes read: 561 KiB
            estimated row count: 9,998 (100% of the table; stats collected 29 minutes ago)
            table: vehicles@primary
            spans: FULL SCAN
(29 rows)

Time: 20ms total (execution 19ms / network 1ms)
```



