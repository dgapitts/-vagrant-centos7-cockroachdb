# Big table commands and simple test results



Commands

```
create table big_table(id int,filler varchar(100) default '0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789');
```


Increasinig big inerts

```
insert into big_table(id) SELECT generate_series(1,100);
insert into big_table(id) SELECT generate_series(1,1000);
insert into big_table(id) SELECT generate_series(1,10000);
insert into big_table(id) SELECT generate_series(1,100000);
insert into big_table(id) SELECT generate_series(1,1000000);
insert into big_table(id) SELECT generate_series(1,10000000);
```

Cleanup

```
truncate table big_table;
```


Simple results on 3-node cluster running on docker on my laptop

```
root@roach2:26258/defaultdb> create table big_table(id int,filler varchar(100) default '0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789');
CREATE TABLE

Time: 19ms total (execution 18ms / network 0ms)

root@roach2:26258/defaultdb> insert into big_table(id) SELECT generate_series(1,100);
INSERT 0 100

Time: 39ms total (execution 38ms / network 1ms)

root@roach2:26258/defaultdb> insert into big_table(id) SELECT generate_series(1,1000000);
INSERT 0 1000000

Time: 7.760s total (execution 7.759s / network 0.001s)

root@roach2:26258/defaultdb> insert into big_table(id) SELECT generate_series(1,10000000);
INSERT 0 10000000

Time: 101.347s total (execution 101.344s / network 0.004s)

root@roach2:26258/defaultdb> truncate table big_table;
TRUNCATE

Time: 273ms total (execution 272ms / network 0ms)
```


