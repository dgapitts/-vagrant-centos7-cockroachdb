# Transaction management

I was a bit surprised that the first session started failed to commit (TransactionAbortedError) but the second one was able to commit.



## Session one - OPEN first transaction FROM bank.accounts WHERE type = 'checking' AND customer_id = 2;

```
root@:26257/defaultdb> BEGIN;
BEGIN

Time: 88ms total (execution 335ms / network 88ms)

root@:26257/defaultdb  OPEN> SELECT balance >= 200 FROM bank.accounts WHERE type = 'checking' AND customer_id = 2;
  ?column?
------------
    true
(1 row)

Time: 1.147s total (execution 1.097s / network 0.050s)

root@:26257/defaultdb  OPEN> UPDATE bank.accounts SET balance = balance - 200 WHERE type = 'checking' AND customer_id = 2;
UPDATE 1

Time: 987ms total (execution 952ms / network 35ms)

```



## Session two - OPEN second transaction FROM bank.accounts WHERE type = 'checking' AND customer_id = 2;

```
root@:26257/defaultdb> BEGIN;
BEGIN

root@:26257/defaultdb  OPEN> SELECT balance >= 200 FROM bank.accounts WHERE type = 'checking' AND customer_id = 2;
  ?column?
------------
    true
(1 row)

Time: 36.894s total (execution 36.640s / network 0.254s)

root@:26257/defaultdb  OPEN> UPDATE bank.accounts SET balance = balance - 200 WHERE type = 'checking' AND customer_id = 2;
UPDATE 1

Time: 907ms total (execution 880ms / network 26ms)
```




## Session one - fails to commit

```
root@:26257/defaultdb  OPEN> commit;
ERROR: restart transaction: TransactionRetryWithProtoRefreshError: TransactionAbortedError(ABORT_REASON_CLIENT_REJECT): "sql txn" meta={id=67c73256 key=/Table/55/1/655093594481393667/0 pri=0.00333516 epo=0 ts=1619989470.174705286,0 min=1619989470.174705286,0 seq=1} lock=true stat=PENDING rts=1619989470.174705286,0 wto=false max=1619989470.674705286,0
SQLSTATE: 40001
HINT: See: https://www.cockroachlabs.com/docs/v20.2/transaction-retry-error-reference.html#abort_reason_client_reject
```

## Session two - can commit

```
root@:26257/defaultdb  OPEN> commit;
COMMIT
```


