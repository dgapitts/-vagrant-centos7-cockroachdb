# Sorting and Indexes

## Regular explain - FULL SCAN + FILTER operation (no index usage)

```
root@localhost:26257/movr> EXPLAIN SELECT id, battery FROM vehicles WHERE battery > 80 AND battery <= 90;
                                          info
----------------------------------------------------------------------------------------
  distribution: full
  vectorized: true

  • filter
  │ estimated row count: 1,002
  │ filter: (battery > 80) AND (battery <= 90)
  │
  └── • scan
        estimated row count: 9,998 (100% of the table; stats collected 17 seconds ago)
        table: vehicles@primary
        spans: FULL SCAN
(11 rows)

Time: 1ms total (execution 1ms / network 0ms)
```

## Trace query - FULL SCAN + FILTER operation (no index usage)

```

root@localhost:26257/movr> EXPLAIN ANALYZE SELECT id, battery FROM vehicles WHERE battery > 80 AND battery <= 90;
                                          info
----------------------------------------------------------------------------------------
  planning time: 2ms
  execution time: 9ms
  distribution: full
  vectorized: true
  rows read from KV: 9,998 (561 KiB)
  cumulative time spent in KV: 7ms
  maximum memory usage: 160 KiB
  network usage: 30 KiB (12 messages)

  • filter
  │ cluster nodes: n2
  │ actual row count: 1,002
  │ estimated row count: 1,002
  │ filter: (battery > 80) AND (battery <= 90)
  │
  └── • scan
        cluster nodes: n2
        actual row count: 9,998
        KV rows read: 9,998
        KV bytes read: 561 KiB
        estimated row count: 9,998 (100% of the table; stats collected 37 seconds ago)
        table: vehicles@primary
        spans: FULL SCAN
(23 rows)

Time: 12ms total (execution 11ms / network 0ms)

```
## Trace query - now with extra ORDER BY clause  - FULL SCAN + FILTER operation + SORT operation

```
root@localhost:26257/movr> EXPLAIN ANALYZE SELECT id, battery FROM vehicles WHERE battery > 80 AND battery <= 90 order by battery;
                                            info
--------------------------------------------------------------------------------------------
  planning time: 694µs
  execution time: 10ms
  distribution: full
  vectorized: true
  rows read from KV: 9,998 (561 KiB)
  cumulative time spent in KV: 6ms
  maximum memory usage: 190 KiB
  network usage: 28 KiB (3 messages)

  • sort
  │ cluster nodes: n2
  │ actual row count: 1,002
  │ estimated row count: 1,002
  │ order: +battery
  │
  └── • filter
      │ cluster nodes: n2
      │ actual row count: 1,002
      │ estimated row count: 1,002
      │ filter: (battery > 80) AND (battery <= 90)
      │
      └── • scan
            cluster nodes: n2
            actual row count: 9,998
            KV rows read: 9,998
            KV bytes read: 561 KiB
            estimated row count: 9,998 (100% of the table; stats collected 47 seconds ago)
            table: vehicles@primary
            spans: FULL SCAN
(29 rows)

Time: 11ms total (execution 11ms / network 0ms)
```

## Add index

```
root@localhost:26257/movr> CREATE INDEX ON vehicles (battery);
CREATE INDEX

Time: 483ms total (execution 27ms / network 455ms)
```
## Trace query - with extra ORDER BY clause  - now using single INDEX SCAN operation

Note the above three `FULL SCAN operation + FILTER operation + SORT operation` is replaced by a single  `INDEX SCAN operation`

```
root@localhost:26257/movr> EXPLAIN ANALYZE SELECT id, battery FROM vehicles WHERE battery > 80 AND battery <= 90 order by battery;
                                      info
---------------------------------------------------------------------------------
  planning time: 523µs
  execution time: 2ms
  distribution: local
  vectorized: true
  rows read from KV: 1,002 (45 KiB)
  cumulative time spent in KV: 2ms
  maximum memory usage: 120 KiB
  network usage: 0 B (0 messages)

  • scan
    cluster nodes: n1
    actual row count: 1,002
    KV rows read: 1,002
    KV bytes read: 45 KiB
    estimated row count: 989 (9.9% of the table; stats collected 4 seconds ago)
    table: vehicles@vehicles_battery_idx
    spans: [/81 - /90]
(17 rows)

Time: 3ms total (execution 3ms / network 0ms)
```

## Trace query - with extra ORDER BY ... DESC clause  - now using single INDEX REVSCAN operation

The same performance, the only difference is that we are running a REVSCAN on the index 

```
root@localhost:26257/movr> EXPLAIN ANALYZE SELECT id, battery FROM vehicles WHERE battery > 80 AND battery <= 90 order by battery desc;
                                       info
----------------------------------------------------------------------------------
  planning time: 498µs
  execution time: 3ms
  distribution: local
  vectorized: true
  rows read from KV: 1,002 (45 KiB)
  cumulative time spent in KV: 2ms
  maximum memory usage: 120 KiB
  network usage: 0 B (0 messages)

  • revscan
    cluster nodes: n1
    actual row count: 1,002
    KV rows read: 1,002
    KV bytes read: 45 KiB
    estimated row count: 989 (9.9% of the table; stats collected 30 seconds ago)
    table: vehicles@vehicles_battery_idx
    spans: [/81 - /90]
(17 rows)

Time: 4ms total (execution 4ms / network 0ms)


```

NB and re-running the previous version I also get 4ms again 

```
root@localhost:26257/movr> EXPLAIN ANALYZE SELECT id, battery FROM vehicles WHERE battery > 80 AND battery <= 90 order by battery;
                                       info
----------------------------------------------------------------------------------
  planning time: 261µs
  execution time: 3ms
  distribution: local
  vectorized: true
  rows read from KV: 1,002 (45 KiB)
  cumulative time spent in KV: 2ms
  maximum memory usage: 120 KiB
  network usage: 0 B (0 messages)

  • scan
    cluster nodes: n1
    actual row count: 1,002
    KV rows read: 1,002
    KV bytes read: 45 KiB
    estimated row count: 989 (9.9% of the table; stats collected 52 seconds ago)
    table: vehicles@vehicles_battery_idx
    spans: [/81 - /90]
(17 rows)

Time: 4ms total (execution 3ms / network 0ms)
```



