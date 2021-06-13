# setup python cockroachdb env and first sqlalchemy exercises

Ref: https://docs.sqlalchemy.org/en/13/orm/session_api.html#sqlalchemy.orm.session.Session.add


I suspect you need python3.6 or higher (my old ubuntu desktop was on python3.5 are the pip install was not 100% clean)
```
python3 -m venv env
source env/bin/activate
pip -V
pip install docopt flask flask-bootstrap flask-login flask-wtf             sqlalchemy sqlalchemy-cockroachdb psycopg2-binary geopy python-dotenv
```

I unpack the exercise files 
```
mv ~/Downloads/movr.zip .
unzip movr.zip
```

load the initial data (note the vehicles_data_with_lat_long.sql in the download doesn't have the table definition which was in my vehicles_data_with_lat_long.sql file from my last exercise)

```
./start_cluster_single-node.sh
time cat vehicles_data_with_lat_long.sql | cockroach sql --host localhost:26257 --insecure
time cat movr/data/vehicles_data_with_lat_long.sql | cockroach sql --host localhost:26257 --insecure
```

to start the first exercise:

```
cd movr/lab_add_vehicle/movr_py_add_vehicle/
./server.py --help
./server.py run --url 'postgres://root@localhost:26257/movr?sslmode=disable'
```

you can then make your code chanegs eg in `movr/lab_add_vehicle/movr_py_add_vehicle/movr/transactions.py`

```
def remove_vehicle_txn(session, vehicle_id):
    """
    Deletes a vehicle row from the vehicles table.

    Arguments:
        session {.Session} -- The active session for the database connection.
        vehicle_id {UUID} -- The vehicle's unique ID.

    Returns:
        {None} -- vehicle isn't found
        True {Boolean} -- vehicle is deleted
    """
    # find the row.
    # SELECT * FROM vehicles WHERE id = <vehicle_id> AND in_use = false;
    vehicle = session.query(Vehicle).filter(Vehicle.id == vehicle_id). \
                                     filter(Vehicle.in_use == False).first()

    if vehicle is None:  # Either vehicle is in use or it's been deleted
        return None

    # Vehicle has been found. Delete it.

    # TO COMPLETE THE "REMOVE VEHICLES" LAB, WRITE THE COMMAND 
    # TO DELETE THE CORRECT VEHICLE HERE.
    # YOU WILL NEED TO USE THE 'session' OBJECT.
    # YOU MAY FIND THIS LINK IN THE SQLALCHEMY DOCS USEFUL:
    # https://docs.sqlalchemy.org/en/13/orm/session_api.html#sqlalchemy.orm.session.Session.delete

    session.delete(vehicle)
```

