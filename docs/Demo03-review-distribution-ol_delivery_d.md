## Demo03 review data distribution for ol_delivery_d (order_line delivery_date)

Hmm... not too great actually:
```
root@localhost:26257/tpcc> select left(ol_delivery_d::text,19), count(*) from order_line group by left(ol_delivery_d::text,19) order by 1;
         left         |  count
----------------------+----------
  NULL                |  899134
  2006-01-02 15:04:05 | 2102088
(2 rows)

Time: 6.465s total (execution 6.465s / network 0.000s)
```

also interesting the optimizer choose to run the query (aggregating data over 3 million rows) using two nodes
```
root@localhost:26257/tpcc> explain analyze select left(ol_delivery_d::text,19), count(*) from order_line group by left(ol_delivery_d::text,19) order by 1;
                                             info
-----------------------------------------------------------------------------------------------
  planning time: 599µs
  execution time: 7.3s
  distribution: full
  vectorized: true
  rows read from KV: 3,001,222 (216 MiB)
  cumulative time spent in KV: 2.9s
  maximum memory usage: 60 KiB
  network usage: 256 B (7 messages)

  • sort
  │ nodes: n1, n2
  │ actual row count: 2
  │ estimated row count: 2
  │ order: +column14
  │
  └── • group
      │ nodes: n1, n2
      │ actual row count: 2
      │ estimated row count: 2
      │ group by: column14
      │
      └── • render
          │ nodes: n1, n2
          │ actual row count: 3,001,222
          │ KV rows read: 3,001,222
          │ KV bytes read: 216 MiB
          │ estimated row count: 3,001,222
          │
          └── • scan
                nodes: n1, n2
                actual row count: 3,001,222
                KV rows read: 3,001,222
                KV bytes read: 216 MiB
                estimated row count: 3,001,222 (100% of the table; stats collected 1 day ago)
                table: order_line@primary
                spans: FULL SCAN
(36 rows)

Time: 7.288s total (execution 7.287s / network 0.000s)
```