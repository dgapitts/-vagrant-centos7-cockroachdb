# vagrant-centos7-cockroachdb

## Base centos7 cockroachDB via vagrant

Prerequisites
- Virtualbox (from Oracle)
- Vagrant (from Hashicorp)
for Linux and Mac this can be done easily by the package manager (yum or apt-get or brew)

then
- download or git clone vagrant-centos7-cockroachdb
- run vagrant up
```
[~/projects/vagrant-centos7-npm] vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'https://cloud.centos.org/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1804_02.VirtualBox.box'...
==> default: Matching MAC address for NAT networking...
==> default: Setting the name of the VM: vagrant-centos7-cockroachdb_default_1618602234014_83235
==> default: Fixed port collision for 22 => 2222. Now on port 2200.
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
==> default: Forwarding ports...
    default: 8081 (guest) => 8081 (host) (adapter 1)
    default: 22 (guest) => 2200 (host) (adapter 1)
==> default: Running 'pre-boot' VM customizations...
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2200
    default: SSH username: vagrant
    default: SSH auth method: private key
    default: 
...                            
    default:   ghc-regex-tdfa.x86_64 0:1.1.8-11.el7                                          
    default:   ghc-syb.x86_64 0:0.4.0-35.el7                                                 
    default:   ghc-text.x86_64 0:0.11.3.1-2.el7                                              
    default:   ghc-time.x86_64 0:1.4.0.1-26.4.el7                                            
    default:   ghc-transformers.x86_64 0:0.3.0.0-34.el7                                      
    default:   ghc-unix.x86_64...
```

the provision.sh script (triggered when the VM is initially built), includes steps to install cockroachDB as per https://www.cockroachlabs.com/docs/stable/install-cockroachdb-linux.html

```
[~/projects/vagrant-centos7-cockroachdb] # cat provision.sh 
#! /bin/bash
if [ ! -f /home/vagrant/already-installed-flag ]
then
  echo "ADD EXTRA ALIAS VIA .bashrc"
  cat /vagrant/bashrc.append.txt >> /home/vagrant/.bashrc

  #echo "GENERAL YUM UPDATE"
  #yum -y update
  #echo "INSTALL GIT"
  yum -y install git
  #echo "INSTALL TREE"
  yum -y install tree
  #echo "INSTALL unzip curl wget lsof"
  yum  -y install unzip curl wget lsof 

  # https://www.cockroachlabs.com/docs/stable/install-cockroachdb-linux.html
  wget -qO- https://binaries.cockroachdb.com/cockroach-v20.2.7.linux-amd64.tgz | tar xvz
  cp -i cockroach-v20.2.7.linux-amd64/cockroach /usr/local/bin/
  mkdir -p /usr/local/lib/cockroach
  cp -i cockroach-v20.2.7.linux-amd64/lib/libgeos.so /usr/local/lib/cockroach/
  cp -i cockroach-v20.2.7.linux-amd64/lib/libgeos_c.so /usr/local/lib/cockroach/

  # Add ShellCheck https://github.com/koalaman/shellcheck - a great tool for testing and improving the quality of shell scripts
  yum -y install epel-release
  yum -y install ShellCheck

else
  echo "already installed flag set : /home/vagrant/already-installed-flag"
fi
```

## Quick demo - after VM is built

Connect to the new vagrant VM

```
[~/projects/vagrant-centos7-cockroachdb] # vagrant ssh
[c7cockroach:vagrant:~] # which cockroach
/usr/local/bin/cockroach
```

and continuing examples in https://www.cockroachlabs.com/docs/stable/install-cockroachdb-linux.html

```
[c7cockroach:vagrant:~] # cockroach demo
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
#   (console) http://127.0.0.1:46184
#   (sql)     postgres://root:admin@?host=%2Ftmp%2Fdemo128016152&port=26257
#   (sql/tcp) postgres://root:admin@127.0.0.1:42957?sslmode=require
# 
# 
# The user "root" with password "admin" has been created. Use it to access the Web UI!
#
# Server version: CockroachDB CCL v20.2.7 (x86_64-unknown-linux-gnu, built 2021/03/29 17:52:00, go1.13.14) (same version as client)
# Cluster ID: efd96d1d-082e-4d14-8b5f-59d4e56c1284
# Organization: Cockroach Demo
#
# Enter \? for a brief introduction.
#
root@127.0.0.1:42957/movr> SELECT ST_IsValid(ST_MakePoint(1,2));
  st_isvalid
--------------
     true
(1 row)

Time: 1ms total (execution 1ms / network 0ms)
```


