## Explain plans and secondary indexes

Background: [create_users_table_index_and_sample_queries.sql](create_users_table_index_and_sample_queries.sql)


Very simple table setup:

```
CREATE TABLE users (id INT PRIMARY KEY,
                    last_name STRING NOT NULL,
                    first_name STRING NOT NULL,
                    country STRING,
                    city STRING);
INSERT INTO users (id, last_name, first_name, country, city)
     VALUES (1, 'Cross', 'William', 'USA', 'Jersey City'),
            (2, 'Seldess', 'Jesse', 'USA', 'New York'),
            (3, 'Hirata', 'Lauren', 'USA', 'New York'),
            (4, 'Cross', 'Zachary', 'USA', 'Seattle'),
            (5, 'Shakespeare', 'William', 'UK', 'Stratford-upon-Avon');
```

Table Scan plan (no where clause - get every row) 

```
root@localhost:26257/defaultdb> EXPLAIN SELECT * FROM users;
  tree |     field     |  description
-------+---------------+----------------
       | distribution  | full
       | vectorized    | false
  scan |               |
       | missing stats |
       | table         | users@primary
       | spans         | FULL SCAN
(6 rows)

Time: 4ms total (execution 3ms / network 1ms)
```

Regular search by primary key

```
SHOW INDEXES FROM users;
SELECT * FROM users WHERE id = 1;
EXPLAIN SELECT * FROM users WHERE id = 1;

  table_name | index_name | non_unique | seq_in_index | column_name | direction | storing | implicit
-------------+------------+------------+--------------+-------------+-----------+---------+-----------
  users      | primary    |   false    |            1 | id          | ASC       |  false  |  false
(1 row)

Time: 6ms total (execution 5ms / network 1ms)

  id | last_name | first_name | country |    city
-----+-----------+------------+---------+--------------
   1 | Cross     | William    | USA     | Jersey City
(1 row)

Time: 2ms total (execution 2ms / network 0ms)

  tree |        field        |  description
-------+---------------------+----------------
       | distribution        | local
       | vectorized          | false
  scan |                     |
       | estimated row count | 1
       | table               | users@primary
       | spans               | [/1 - /1]
(6 rows)

Time: 1ms total (execution 1ms / network 0ms)

```
No secondary indexes (yet)
```
EXPLAIN SELECT * FROM users WHERE last_name = 'Cross' AND first_name = 'William';

    tree    |        field        |                    description
------------+---------------------+-----------------------------------------------------
            | distribution        | full
            | vectorized          | false
  filter    |                     |
   │        | filter              | (last_name = 'Cross') AND (first_name = 'William')
   └── scan |                     |
            | estimated row count | 5
            | table               | users@primary
            | spans               | FULL SCAN
(8 rows)

Time: 2ms total (execution 1ms / network 0ms)

```

Adding a secondary indexes 
```
CREATE INDEX my_index ON users (last_name, first_name);
SHOW INDEXES FROM users;
EXPLAIN SELECT * FROM users WHERE last_name = 'Cross' AND first_name = 'William';

Time: 376ms total (execution 75ms / network 301ms)

  table_name | index_name | non_unique | seq_in_index | column_name | direction | storing | implicit
-------------+------------+------------+--------------+-------------+-----------+---------+-----------
  users      | primary    |   false    |            1 | id          | ASC       |  false  |  false
  users      | my_index   |    true    |            1 | last_name   | ASC       |  false  |  false
  users      | my_index   |    true    |            2 | first_name  | ASC       |  false  |  false
  users      | my_index   |    true    |            3 | id          | ASC       |  false  |   true
(4 rows)

Time: 4ms total (execution 3ms / network 0ms)

    tree    |        field        |                    description
------------+---------------------+-----------------------------------------------------
            | distribution        | full
            | vectorized          | false
  filter    |                     |
   │        | filter              | (last_name = 'Cross') AND (first_name = 'William')
   └── scan |                     |
            | estimated row count | 5
            | table               | users@primary
            | spans               | FULL SCAN
(8 rows)

Time: 2ms total (execution 1ms / network 1ms)


```


