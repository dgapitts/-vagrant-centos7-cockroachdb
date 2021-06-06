


    1  cd /vagrant/
    2  time cat movr/data/vehicles_data_with_lat_long.sql | cockroach sql --host localhost:26257 --insecure
    3  cockroach sql --host localhost:26257 --insecure
    4  # "postgres://root:localhost:26257?sslmode=disable"
    5  cockroach sql --help




    1  cd /vagrant/
    2  ./start_cluster_single-node.sh 
    3  lt
    4  cd movr/lab_add_vehicle/movr_py_add_vehicle/
    5  ./server.py --help
    6  sudo -i
    7  ./server.py --help
    8  python3 -m venv env
    9  source env/bin/activate
   10  pip -version
   11  pip -v
   12  pip -V
   13  pip install docopt flask flask-bootstrap flask-login flask-wtf             sqlalchemy sqlalchemy-cockroachdb psycopg2-binary geopy python-dotenv 
   14  h40
   15  ./server.py --help
   16  ls -ltr
   17  ./server.py --run
   18  ./server.py run
   19  ./server.py run "postgres://root:localhost:26257"
   20  ./server.py --help
   21  ./server.py run --url "postgres://root:localhost:26257"
   22  ./server.py run --url "postgres://root:localhost:26257 --insecure"
   23  ./server.py run --url "postgres://root:localhost:26257?sslmode=disable"
   24  cockroach start-single-node --insecure
   25  cockroach sql --url "postgres://root:localhost:26257?sslmode=disable"
   26  cockroach sql --url 'postgres://root@localhost:26257?sslmode=disable'
   27  ./server.py run --url 'postgres://root@localhost:26257?sslmode=disable'
   28  ./server.py run --url 'postgres://movr@localhost:26257?sslmode=disable'
   29  ./server.py run --url 'postgres://root@localhost:26257?sslmode=disable'
   30  ./server.py --help
   31  vi .env
   32  ./server.py run --url 'postgres://root@localhost:26257?sslmode=disable'
   33  ./server.py run --url 'postgres://root@localhost:26257/movr?sslmode=disable'
   34  h



