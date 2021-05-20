SHOW RANGES FROM TABLE movr.vehicles;

ALTER TABLE movr.vehicles
PARTITION BY LIST (city) (
    PARTITION new_york VALUES IN ('new york'),
    PARTITION boston VALUES IN ('boston'),
    PARTITION washington_dc VALUES IN ('washington dc'),
    PARTITION seattle VALUES IN ('seattle'),
    PARTITION san_francisco VALUES IN ('san francisco'),
    PARTITION los_angeles VALUES IN ('los angeles')
);

ALTER PARTITION new_york OF TABLE movr.vehicles
CONFIGURE ZONE USING constraints='[+region=us-east]';

ALTER PARTITION boston OF TABLE movr.vehicles
CONFIGURE ZONE USING constraints='[+region=us-east]';

ALTER PARTITION washington_dc OF TABLE movr.vehicles
CONFIGURE ZONE USING constraints='[+region=us-central]';

ALTER PARTITION seattle OF TABLE movr.vehicles
CONFIGURE ZONE USING constraints='[+region=us-west]';

ALTER PARTITION san_francisco OF TABLE movr.vehicles
CONFIGURE ZONE USING constraints='[+region=us-west]';

ALTER PARTITION los_angeles OF TABLE movr.vehicles
CONFIGURE ZONE USING constraints='[+region=us-west]';

SELECT start_key, end_key, lease_holder_locality, replicas, replica_localities FROM [SHOW RANGES FROM TABLE movr.vehicles]
WHERE "start_key" NOT LIKE '%Prefix%' AND "end_key" NOT LIKE '%Prefix';
