#!/bin/bash -evx

PGVERSION=$1
DATABASE=$2
VPC_CIDR=$3

. ./postgresenv.sh $PGVERSION

sudo apt-get -qq update && sudo apt-get -qq -y install python-software-properties software-properties-common && \
    sudo add-apt-repository "deb http://gb.archive.ubuntu.com/ubuntu $(lsb_release -sc) universe" && \
    sudo apt-get -qq update

sudo apt-get -qq -y install debconf-utils

sudo add-apt-repository -y ppa:saiarcot895/myppa && \
    sudo apt-get -qq update && \
    sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y install apt-fast

sudo apt-fast -qq -y install git python-dev wget sudo vim

# Install python3 tools for the wal-e install
sudo apt-get -y install python3-pip
pip3 install --upgrade pip

pushd /tmp
sudo wget --quiet https://bootstrap.pypa.io/get-pip.py && sudo python get-pip.py
popd

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``${POSTGRES_VERSION}``.
sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main"

sudo apt-fast -qq update

sudo apt-fast -y -qq install postgresql-${POSTGRES_VERSION} postgresql-client-${POSTGRES_VERSION} postgresql-contrib-${POSTGRES_VERSION} postgresql-server-dev-${POSTGRES_VERSION} libpq5 libpq-dev postgresql-${POSTGRES_VERSION}-postgis-2.2

#Fix locale warnings when starting postgres
sudo locale-gen en_US.UTF-8 && \
    sudo dpkg-reconfigure --frontend=noninteractive locales

###WAL-E
#USER root
#https://coderwall.com/p/cwe2_a/backup-and-recover-a-postgres-db-using-wal-e
sudo apt-fast -qq -y install libffi-dev
sudo pip install --upgrade distribute
sudo pip install -U six

# wal-e v1 and later now require python3
sudo pip3 install wal-e

sudo apt-fast -qq install -y daemontools lzop pv
sudo pip install -U requests==2.12.5

sudo mkdir -p ${POSTGRESDBDIR}
sudo mkdir -p /media/data/postgres/xlog/transactions
sudo chown -R postgres:postgres /media/data/postgres

sudo chown -R postgres:postgres /var/lib/postgresql


sudo su -c "./config.sh ${POSTGRES_VERSION} ${DATABASE} ${VPC_CIDR} " -s /bin/sh postgres

./xlog.sh $POSTGRES_VERSION
./supervisorconfig.sh $POSTGRES_VERSION

sudo service postgresql stop

#disable init.d autostart
sudo update-rc.d postgresql disable

sudo pip install s3cmd==1.6.1
sudo pip install -U setuptools

# Create a couple of standard temp directories
sudo mkdir -p /media/data/tmp
sudo chmod 777 /media/data/tmp
sudo mkdir -p /media/data/db_restore
sudo chmod 777 /media/data/db_restore
