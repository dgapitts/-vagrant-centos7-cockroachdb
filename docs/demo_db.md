## Exploring demo db

To start the temporary, in-memory, single node demo db, just type `cockroach demo`

```
[c7cockroach:vagrant:/vagrant] # cockroach demo
#
# Welcome to the CockroachDB demo database!
#
# You are connected to a temporary, in-memory CockroachDB cluster of 1 node.
#
# This demo session will attempt to enable enterprise features
# by acquiring a temporary license from Cockroach Labs in the background.
# To disable this behavior, set the environment variable
# COCKROACH_SKIP_ENABLING_DIAGNOSTIC_REPORTING=true.
#
# Beginning initialization of the movr dataset, please wait...
#
# The cluster has been preloaded with the "movr" dataset
# (MovR is a fictional vehicle sharing company).
#
# Reminder: your changes to data stored in the demo session will not be saved!
#
# Connection parameters:
#   (console) http://127.0.0.1:35501
#   (sql)     postgres://root:admin@?host=%2Ftmp%2Fdemo223587282&port=26257
#   (sql/tcp) postgres://root:admin@127.0.0.1:43159?sslmode=require
# 
# 
# The user "root" with password "admin" has been created. Use it to access the Web UI!
#
# Server version: CockroachDB CCL v20.2.7 (x86_64-unknown-linux-gnu, built 2021/03/29 17:52:00, go1.13.14) (same version as client)
# Cluster ID: fa00f6d8-253b-4412-9fd7-ae89a6d5b68a
# Organization: Cockroach Demo
#
# Enter \? for a brief introduction.
#
root@127.0.0.1:43159/movr> \?
You are using 'cockroach sql', CockroachDB's lightweight SQL client.
Type:
  \? or "help"      print this help.
  \q, quit, exit    exit the shell (Ctrl+C/Ctrl+D also supported).
  \! CMD            run an external command and print its results on standard output.
  \| CMD            run an external command and run its output as SQL statements.
  \set [NAME]       set a client-side flag or (without argument) print the current settings.
  \unset NAME       unset a flag.
  \show             during a multi-line statement or transaction, show the SQL entered so far.
  \h [NAME]         help on syntax of SQL commands.
  \hf [NAME]        help on SQL built-in functions.
  \l                list all databases in the CockroachDB cluster.
  \dt               show the tables of the current schema in the current database.
  \dT               show the user defined types of the current database.
  \du               list the users for all databases.
  \d [TABLE]        show details about columns in the specified table, or alias for '\dt' if no table is specified.

Commands specific to the demo shell (EXPERIMENTAL):
  \demo ls                     list the demo nodes and their connection URLs.
  \demo shutdown <nodeid>      stop a demo node.
  \demo restart <nodeid>       restart a stopped demo node.
  \demo decommission <nodeid>  decommission a node.
  \demo recommission <nodeid>  recommission a node.

More documentation about our SQL dialect and the CLI shell is available online:
https://www.cockroachlabs.com/docs/v20.2/sql-statements.html
https://www.cockroachlabs.com/docs/v20.2/use-the-built-in-sql-client.html
```

## List 4 database (using the postgres psql \l command)
```
root@127.0.0.1:43159/movr> \l
  database_name | owner
----------------+--------
  defaultdb     | root
  movr          | root
  postgres      | root
  system        | node
(4 rows)

Time: 107ms total (execution 78ms / network 29ms)
```

## List 6 tables (using the postgres psql \d command)

```
root@127.0.0.1:43159/movr> \d
  schema_name |         table_name         | type  | owner | estimated_row_count
--------------+----------------------------+-------+-------+----------------------
  public      | promo_codes                | table | root  |                   0
  public      | rides                      | table | root  |                   0
  public      | user_promo_codes           | table | root  |                   0
  public      | users                      | table | root  |                   0
  public      | vehicle_location_histories | table | root  |                   0
  public      | vehicles                   | table | root  |                   0
(6 rows)

Time: 183ms total (execution 183ms / network 0ms)
```


```
root@127.0.0.1:43159/movr> \d users
  column_name | data_type | is_nullable | column_default | generation_expression |  indices  | is_hidden
--------------+-----------+-------------+----------------+-----------------------+-----------+------------
  id          | UUID      |    false    | NULL           |                       | {primary} |   false
  city        | VARCHAR   |    false    | NULL           |                       | {primary} |   false
  name        | VARCHAR   |    true     | NULL           |                       | {}        |   false
  address     | VARCHAR   |    true     | NULL           |                       | {}        |   false
  credit_card | VARCHAR   |    true     | NULL           |                       | {}        |   false
(5 rows)

Time: 87ms total (execution 86ms / network 1ms)
```

root@127.0.0.1:43159/movr> \d+ users
Suggestion: use the SQL SHOW statement to inspect your schema.
invalid syntax: \d+ users. Try \? for help.
root@127.0.0.1:43159/movr> \z users
invalid syntax: \z users. Try \? for help.
root@127.0.0.1:43159/movr> \dpp users
Suggestion: use the SQL SHOW statement to inspect your schema.
invalid syntax: \dpp users. Try \? for help.

```
root@127.0.0.1:43159/movr> select count(*) from users;
  count
---------
     50
(1 row)

Time: 1.061s total (execution 0.876s / network 0.185s)

root@127.0.0.1:43159/movr> explain select count(*) from users;
       tree      |        field        |  description
-----------------+---------------------+----------------
                 | distribution        | full
                 | vectorized          | false
  group (scalar) |                     |
   └── scan      |                     |
                 | estimated row count | 50
                 | table               | users@primary
                 | spans               | FULL SCAN
(7 rows)

Time: 645ms total (execution 619ms / network 26ms)

root@127.0.0.1:43159/movr> explain select count(*), city from users group by city;
    tree    |        field        |  description
------------+---------------------+----------------
            | distribution        | full
            | vectorized          | false
  group     |                     |
   │        | group by            | city
   │        | ordered             | +city
   └── scan |                     |
            | estimated row count | 50
            | table               | users@primary
            | spans               | FULL SCAN
(9 rows)

Time: 1.142s total (execution 1.003s / network 0.139s)

root@127.0.0.1:43159/movr> explain analyze select count(*), city from users group by city;
  automatic |                                                                                                                                                                                                                                                                                                  url
------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    true    | https://cockroachdb.github.io/distsqlplan/decode.html#eJyUktGL00AQxt_9K4Z5amXtdesdlX1q7qxSjElNUrRKKHvZIQSSbNzd4JXS_12yAc8KFn38Zuab-X7sntB-r1Hg-ss2DDYRBFEQ7r-uYfJ2k2bpp3AK6TpcP2RQ6L51k5dTBkXljvAuiT9Cb8lYeJ_Euy3c730DGbZaUSQbsii-IcecYWd0QdZqM5ROfmCjnlDMGVZt17uhnDMstCEUJ3SVqwkFZvKxpoSkInMzR4aKnKxqv9ZfXnWmaqQZbqadbK2AV8gw7p2A1QIZGv3DgiGpBNwNfutkXYOrGhJwx_nsze2yscjw8ejo1-BsCR-qe8zPDHXvnsNZJ0tCwc_s3wGCsjRUSqfNDb_Mvxp0bBQZUgK8CqL9IYqzQ7QLw8mKT5HhQ7yLskMSf04n02cy5sevwb1ezvjy1rM18gkaarQ5Dq-lBCzmV_kW_8OXkO10a-mC7W-b5-ecIamSxk9gdW8K2hpd-DOjjL3PFxRZN3b5KDbt2BoC_m7mV82LP8z5-cXPAAAA__9CEu2Y
(1 row)

Time: 2.059s total (execution 2.032s / network 0.027s)
```
![explain-analyze-links-to-github.io.png](explain-analyze-links-to-github.io.png)
```
root@127.0.0.1:43159/movr> select count(*) from vehicle_location_histories;
  count
---------
   1000
(1 row)

Time: 2.189s total (execution 1.942s / network 0.247s)

root@127.0.0.1:43159/movr> \d vehicle_location_histories
  column_name | data_type | is_nullable | column_default | generation_expression |  indices  | is_hidden
--------------+-----------+-------------+----------------+-----------------------+-----------+------------
  city        | VARCHAR   |    false    | NULL           |                       | {primary} |   false
  ride_id     | UUID      |    false    | NULL           |                       | {primary} |   false
  timestamp   | TIMESTAMP |    false    | NULL           |                       | {primary} |   false
  lat         | FLOAT8    |    true     | NULL           |                       | {}        |   false
  long        | FLOAT8    |    true     | NULL           |                       | {}        |   false
(5 rows)

Time: 14.149s total (execution 13.579s / network 0.570s)

root@127.0.0.1:43159/movr> select min(timestamp) from vehicle_location_histories;
             min
-----------------------------
  2019-01-02 03:04:05+00:00
(1 row)

Time: 5.841s total (execution 5.641s / network 0.201s)

root@127.0.0.1:43159/movr> explain select min(timestamp) from vehicle_location_histories;
       tree      |        field        |            description
-----------------+---------------------+-------------------------------------
                 | distribution        | full
                 | vectorized          | true
  group (scalar) |                     |
   └── scan      |                     |
                 | estimated row count | 1000
                 | table               | vehicle_location_histories@primary
                 | spans               | FULL SCAN
(7 rows)

Time: 7.642s total (execution 6.384s / network 1.258s)

Note: an additional delay of 1.000838064s was spent formatting the results.
You can use \set display_format to change the formatting.



