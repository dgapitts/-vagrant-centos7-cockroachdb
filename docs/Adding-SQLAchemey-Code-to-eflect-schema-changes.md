# Adding SQLAchemey Code to eflect schema changes 


Given we just updated 

```
root@localhost:26257/movr> CREATE TABLE location_history (
    id UUID PRIMARY KEY,
    vehicle_id UUID REFERENCES vehicles(id) ON DELETE CASCADE,
    ts TIMESTAMP NOT NULL,
    longitude FLOAT8 NOT NULL,
    latitude FLOAT8 NOT NULL
);
CREATE TABLE

Time: 493ms total (execution 187ms / network 306ms)
```


In the next lesson, we also had to add `class LocationHistory` to the SQLAchemey ORM

```
Vehicle Class

class Vehicle(Base):
    """
    DeclarativeMeta class for the vehicles table     Arguments:
        Base {DeclarativeMeta} -- Base class for model to inherit.
    """
    __tablename__ = 'vehicles'
    id = Column(UUID)
    last_longitude = Column(Float) # This column gets deleted in the lab
    last_latitude = Column(Float) # This column gets deleted in the lab
    last_checkin = Column(DateTime, default=func.now) # This column gets deleted in the lab
    in_use = Column(Boolean)
    vehicle_type = Column(String)
    battery = Column(Integer)
    PrimaryKeyConstraint(id)

    def __repr__(self):
        return "<Vehicle(id='{0}', vehicle_type='{1}')>".format(
            self.id, self.vehicle_type)
LocationHistory Class

class LocationHistory(Base):
    """
    Table object to store a vehicle's location_history.
    Arguments:
        Base {DeclarativeMeta} -- Base class for declarative SQLAlchemy class
                that produces appropriate `sqlalchemy.schema.Table` objects.
    """
    __tablename__ = 'location_history'
    id = Column(UUID)
    vehicle_id = Column(UUID, ForeignKey('vehicles.id'))
    ts = Column(DateTime, default=func.now)
    longitude = Column(Float)
    latitude = Column(Float)
    PrimaryKeyConstraint(id)
 
    def __repr__(self):
        return (("<Vehicle(id='{0}', vehicle_id='{1}', ts='{2}', "
                 "longitude='{3}', latitude='{4}')>"
                 ).format(self.id, self.vehicle_id, self.ts, self.longitude,
                          self.latitude))
Updating Transactions

def get_vehicle_txn(session, vehicle_id):
    ...
    v = aliased(Vehicle)  # vehicles AS v
    l = aliased(LocationHistory)  # location_history as l
    g = find_most_recent_timestamp_subquery(session)

    # SELECT columns
    vehicle = session.query(v.id, v.in_use, v.vehicle_type, v.battery,
                            l.longitude, l.latitude, l.ts). \
                      filter(l.vehicle_id == v.id). \
                      filter(l.vehicle_id == vehicle_id). \
                      join(g). \
                      filter(g.c.vehicle_id == l.vehicle_id). \
                      filter(g.c.max_ts == l.ts).order_by(v.id). \
                      first()  # LIMIT 1;
```





