
  # https://www.cockroachlabs.com/docs/stable/install-cockroachdb-linux.html
  wget -qO- https://binaries.cockroachdb.com/cockroach-v20.2.7.linux-amd64.tgz | tar xvz
  cp -i cockroach-v20.2.7.linux-amd64/cockroach /usr/local/bin/
  mkdir -p /usr/local/lib/cockroach
  cp -i cockroach-v20.2.7.linux-amd64/lib/libgeos.so /usr/local/lib/cockroach/
  cp -i cockroach-v20.2.7.linux-amd64/lib/libgeos_c.so /usr/local/lib/cockroach/

