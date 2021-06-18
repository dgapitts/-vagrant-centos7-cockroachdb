## Another RI example and Array Data Type

### Table setup 

```
root@localhost:26257/movr> CREATE TABLE users(
    email STRING PRIMARY KEY,
    last_name STRING,
    first_name STRING
);

CREATE TABLE

Time: 160ms total (execution 158ms / network 2ms)

root@localhost:26257/movr> CREATE TABLE rides (
    id UUID PRIMARY KEY,
    vehicle_id UUID REFERENCES vehicles (id),
    user_email STRING REFERENCES users (email),
    start_ts TIMESTAMP,
    end_ts TIMESTAMP
);
CREATE TABLE

Time: 575ms total (execution 199ms / network 376ms)

root@localhost:26257/movr>
```

## Online Alter table operation

Part of this training was emphasize that adding a column is a simple online operation 

```
root@localhost:26257/movr>
ALTER TABLE users ADD COLUMN phone_numbers STRING[];
ALTER TABLE

Time: 718ms total (execution 174ms / network 544ms)
```

NB I'm curious how simple / smooth this is for a large and busy OLTP table  


### Load 10,000 records in 4 sec

```
~/projects/vagrant-centos7-cockroachdb $ time cat movr/data/users_data.sql |cockroach sql --host localhost:26257 --insecure


Time: 18ms

INSERT 100

Time: 37ms

INSERT 100

Time: 32ms

INSERT 100

Time: 57ms

INSERT 100

Time: 19ms


real	0m4.089s
user	0m1.375s
sys	0m0.583s
```

and inspecting the file - it appears to be 100 INSERTS of 100 rows each i.e. 10K 

```
~/projects/vagrant-centos7-cockroachdb $ head -30 movr/data/users_data.sql
/*
CREATE TABLE movr.users (
	email STRING PRIMARY KEY,
	last_name STRING NOT NULL,
	first_name STRING NOT NULL,
	phone_numbers STRING[] NOT NULL
);
*/


INSERT INTO movr.users (email, last_name, first_name, phone_numbers) VALUES
	('Aaron.Ball730@fakeemaildomain.net', 'Ball', 'Aaron', ARRAY['(01x)639-8713x28291']),
	('Aaron.Edwards613@fakeemaildomain.net', 'Edwards', 'Aaron', ARRAY['302x974-1351x63962']),
	('Aaron.Fisher249@fakeemaildomain.net', 'Fisher', 'Aaron', ARRAY['624x349.2116']),
	('Aaron.Foster820@fakeemaildomain.net', 'Foster', 'Aaron', ARRAY['+1-x02-325-0149x09179','(68x)694-1638x436']),
	('Aaron.Gordon258@fakeemaildomain.net', 'Gordon', 'Aaron', ARRAY['+1-x75-675-7022']),
	('Aaron.Greene681@fakeemaildomain.net', 'Greene', 'Aaron', ARRAY['188x367-4765']),
	('Aaron.Hart989@fakeemaildomain.net', 'Hart', 'Aaron', ARRAY['(23x)597-8549x7574']),
	('Aaron.Howard72@fakeemaildomain.net', 'Howard', 'Aaron', ARRAY['719x429-5222x398']),
	('Aaron.Koch778@fakeemaildomain.net', 'Koch', 'Aaron', ARRAY['395x384292']),
	('Aaron.Mcdonald413@fakeemaildomain.net', 'Mcdonald', 'Aaron', ARRAY['+1-x89-168-2133','312x469-8169x35452']),
	('Aaron.Miles567@fakeemaildomain.net', 'Miles', 'Aaron', ARRAY['(18x)973-1395']),
	('Aaron.Proctor820@fakeemaildomain.net', 'Proctor', 'Aaron', ARRAY['461x776-8149x668']),
	('Aaron.Pruitt606@fakeemaildomain.net', 'Pruitt', 'Aaron', ARRAY['832x840.0687']),
	('Aaron.Ramirez478@fakeemaildomain.net', 'Ramirez', 'Aaron', ARRAY['(34x)146-6526x149']),
	('Aaron.Rivers536@fakeemaildomain.net', 'Rivers', 'Aaron', ARRAY['171x342.3411']),
	('Aaron.Ryan199@fakeemaildomain.net', 'Ryan', 'Aaron', ARRAY['584x106-1714x12886','+1-x24-010-1654x27117']),
	('Aaron.Savage768@fakeemaildomain.net', 'Savage', 'Aaron', ARRAY['001x695-453-8819x2203','109x641.9984x04222']),
	('Aaron.Stokes876@fakeemaildomain.net', 'Stokes', 'Aaron', ARRAY['273x935-5995x99951','636x823-6765']),
	('Aaron.Torres560@fakeemaildomain.net', 'Torres', 'Aaron', ARRAY['842x033.7406','(07x)066-8064x41515']),
~/projects/vagrant-centos7-cockroachdb $ grep -c INSERT movr/data/users_data.sql
100
```

similar process for 


```
~/projects/vagrant-centos7-cockroachdb $ time cat movr/data/rides_data.sql |cockroach sql --host localhost:26257 --insecure

...

INSERT 100

Time: 38ms

INSERT 100

Time: 74ms

INSERT 100

Time: 42ms

INSERT 100

Time: 41ms

INSERT 100

Time: 43ms


real	0m5.050s
user	0m1.717s
sys	0m0.693s
```

and finally we run some sanity checks 

```
~/projects/vagrant-centos7-cockroachdb $ cockroach sql --host localhost:26257 --insecure --database=movr
#
# Welcome to the CockroachDB SQL shell.
# All statements must be terminated by a semicolon.
# To exit, type: \q.
#
# Server version: CockroachDB CCL v21.1.1 (x86_64-apple-darwin19, built 2021/05/24 15:00:00, go1.15.11) (same version as client)
# Cluster ID: 56d15f0b-2bcb-4dc5-af6f-d4d629a8d843
#
# Enter \? for a brief introduction.
#
root@localhost:26257/movr> SELECT * FROM rides
WHERE vehicle_id = '44be543d-afe8-4a10-b1f6-c802d0524ded';
                   id                  |              vehicle_id              |                 user_email                 |      start_ts       |       end_ts
---------------------------------------+--------------------------------------+--------------------------------------------+---------------------+----------------------
  04ac1f84-9d37-4268-ade5-ed5f23b2521f | 44be543d-afe8-4a10-b1f6-c802d0524ded | Michael.Cruz795@fakeemaildomain.net        | 2020-07-02 17:27:13 | 2020-07-02 17:28:53
  83d0d4be-3667-4804-9399-c8ae215fd6a8 | 44be543d-afe8-4a10-b1f6-c802d0524ded | Roy.Norton751@fakeemaildomain.net          | 2020-07-05 06:18:59 | 2020-07-05 06:20:39
  92bae14e-48ee-4839-86b0-78cdad1bbef5 | 44be543d-afe8-4a10-b1f6-c802d0524ded | Hernandez.Alexander176@fakeemaildomain.net | 2020-07-03 04:52:23 | 2020-07-03 04:54:03
  d519324e-1d19-4dc8-abaf-959b5575555d | 44be543d-afe8-4a10-b1f6-c802d0524ded | Cameron.Leah775@fakeemaildomain.net        | 2020-07-09 05:43:02 | 2020-07-09 05:44:42
  f84c46b2-5bb0-4f82-97d8-702c94126372 | 44be543d-afe8-4a10-b1f6-c802d0524ded | Andrew.Tanner124@fakeemaildomain.net       | 2020-07-06 10:43:29 | 2020-07-06 10:45:09
(5 rows)

Time: 17ms total (execution 16ms / network 1ms)

root@localhost:26257/movr> UPDATE users SET phone_numbers = array_append(phone_numbers, 'x53-24x-0999')
WHERE last_name = 'Rivera' AND first_name = 'Maria';
UPDATE 1

Time: 675ms total (execution 675ms / network 0ms)
)
root@localhost:26257/movr> select phone_numbers from users WHERE last_name = 'Rivera' AND first_name = 'Maria';
       phone_numbers
-----------------------------
  {705x816758,x53-24x-0999}
```
