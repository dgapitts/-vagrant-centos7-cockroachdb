# cockroach gen haproxy

Thos demo goes beyond the course, to get haproxy setup I followed 
Starting with the standard demo 3-node cluster

```
[c7cockroach:vagrant:/vagrant] # cockroach node status --insecure
  id |     address     |   sql_address   |  build  |            started_at            |            updated_at            | locality | is_available | is_live
-----+-----------------+-----------------+---------+----------------------------------+----------------------------------+----------+--------------+----------
   1 | localhost:26257 | localhost:26257 | v20.2.7 | 2021-05-14 19:46:42.24994+00:00  | 2021-05-14 20:50:13.835269+00:00 |          | true         | true
   2 | localhost:26258 | localhost:26258 | v20.2.7 | 2021-05-14 19:46:42.561682+00:00 | 2021-05-14 20:50:14.153558+00:00 |          | true         | true
   3 | localhost:26259 | localhost:26259 | v20.2.7 | 2021-05-14 19:46:42.917758+00:00 | 2021-05-14 20:50:14.559083+00:00 |          | true         | true
(3 rows)
```

and now 
```
[c7cockroach:vagrant:/vagrant] # cockroach gen haproxy --insecure
[c7cockroach:vagrant:/vagrant] # 
```
which creates an  haproxy.cfg
```
[c7cockroach:vagrant:/vagrant] # ls -ltr|tail -5
-rw-rw-r--. 1 vagrant vagrant    560 May 12 17:51 Vagrantfile
drwxr-x---. 5 vagrant vagrant   4096 May 14 19:49 node1
drwxr-x---. 5 vagrant vagrant   4096 May 14 19:50 node2
drwxr-x---. 5 vagrant vagrant   4096 May 14 19:50 node3
-rw-r--r--. 1 vagrant vagrant    667 May 14 19:50 haproxy.cfg
[c7cockroach:vagrant:/vagrant] # cat haproxy.cfg

global
  maxconn 4096

defaults
    mode                tcp
    # Timeout values should be configured for your specific use.
    # See: https://cbonte.github.io/haproxy-dconv/1.8/configuration.html#4-timeout%20connect
    timeout connect     10s
    timeout client      1m
    timeout server      1m
    # TCP keep-alive on client side. Server already enables them.
    option              clitcpka

listen psql
    bind :26257
    mode tcp
    balance roundrobin
    option httpchk GET /health?ready=1
    server cockroach1 localhost:26257 check port 8080
    server cockroach2 localhost:26258 check port 8081
    server cockroach3 localhost:26259 check port 8082
```

however this didn't actually work

```
[c7cockroach:vagrant:/vagrant] #  haproxy -d -f haproxy.cfg
Available polling systems :
      epoll : pref=300,  test result OK
       poll : pref=200,  test result OK
     select : pref=150,  test result FAILED
Total: 3 (2 usable), will use epoll.
Using epoll() as the polling mechanism.
[WARNING] 133/210739 (7553) : [haproxy.main()] Cannot raise FD limit to 8206.
[ALERT] 133/210739 (7553) : Starting proxy psql: cannot bind socket [0.0.0.0:26257]
```

I spent some time googling this [haproxy_cert_issues.log](haproxy_cert_issues.log) bt no luck yet - I suspect I need to setup a 3 VM cluster with certs?
