# Mac local setup  - brew and manual install notes

There is a brew option, which I would normally use, however it seesms to depend on xcode:

```
~/projects/vagrant-centos7-cockroachdb $ cat provision_mac.sh
set -x

# Option1 - brew notes https://github.com/cockroachdb/homebrew-tap (note I decided not to use for once!)

# brew install cockroachdb/tap/cockroach
# sudo xcodebuild -license accept


# Option2 manual (slimer?) install method - https://www.cockroachlabs.com/docs/stable/install-cockroachdb-mac.html

curl https://binaries.cockroachdb.com/cockroach-v21.1.1.darwin-10.9-amd64.tgz | tar -xz
cp -i cockroach-v21.1.1.darwin-10.9-amd64/cockroach /usr/local/bin/
mkdir -p /usr/local/lib/cockroach
cp -i cockroach-v21.1.1.darwin-10.9-amd64/lib/libgeos.dylib /usr/local/lib/cockroach/
cp -i cockroach-v21.1.1.darwin-10.9-amd64/lib/libgeos_c.dylib /usr/local/lib/cockroach/
which cockroach
```

Now on my old mac, I don't have to much processing power, so went for the manual (slimer?) install method, which only takes a few seconds

```
~/projects/vagrant-centos7-cockroachdb $ time ./provision_mac.sh
++ curl https://binaries.cockroachdb.com/cockroach-v21.1.1.darwin-10.9-amd64.tgz
++ tar -xz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 47.3M  100 47.3M    0     0  27.2M      0  0:00:01  0:00:01 --:--:-- 27.2M
++ cp -i cockroach-v21.1.1.darwin-10.9-amd64/cockroach /usr/local/bin/
++ mkdir -p /usr/local/lib/cockroach
++ cp -i cockroach-v21.1.1.darwin-10.9-amd64/lib/libgeos.dylib /usr/local/lib/cockroach/
++ cp -i cockroach-v21.1.1.darwin-10.9-amd64/lib/libgeos_c.dylib /usr/local/lib/cockroach/
++ which cockroach
/usr/local/bin/cockroach

real	0m3.733s
user	0m0.944s
sys	0m0.789s
```

you can check via `cockroach demo`  i.e. a "temporary, in-memory CockroachDB cluster of 1 node"

```
~ $ cockroach demo
#
# Welcome to the CockroachDB demo database!
#
# You are connected to a temporary, in-memory CockroachDB cluster of 1 node.
#
# This demo session will attempt to enable enterprise features
# by acquiring a temporary license from Cockroach Labs in the background.
# To disable this behavior, set the environment variable
# COCKROACH_SKIP_ENABLING_DIAGNOSTIC_REPORTING=true.
#
# Beginning initialization of the movr dataset, please wait...
#
# The cluster has been preloaded with the "movr" dataset
# (MovR is a fictional vehicle sharing company).
#
# Reminder: your changes to data stored in the demo session will not be saved!
#
# Connection parameters:
#   (webui)    http://127.0.0.1:8080/demologin?password=demo63361&username=demo
#   (sql)      postgres://demo:demo63361@127.0.0.1:26257?sslmode=require
#   (sql/unix) postgres://demo:demo63361@?host=%2Fvar%2Ffolders%2Fn5%2Fnpjt7p592n37h6xpw11yppqc0000gp%2FT%2Fdemo586258532&port=26257
#
#
# The user "demo" with password "demo63361" has been created. Use it to access the Web UI!
#
# Server version: CockroachDB CCL v21.1.1 (x86_64-apple-darwin19, built 2021/05/24 15:00:00, go1.15.11) (same version as client)
# Cluster ID: 5add3018-d7ab-4c3f-a3f6-796d99772baa
# Organization: Cockroach Demo
#
# Enter \? for a brief introduction.
#
demo@127.0.0.1:26257/movr>
```







