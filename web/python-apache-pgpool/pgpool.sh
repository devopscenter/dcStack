#!/bin/bash -e

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
sudo wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
      sudo apt-key add -

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.4``.
sudo echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

sudo sudo apt-fast update

sudo sudo apt-fast -y -q install postgresql-client-$POSTGRES_VERSION libpq5 libpq-dev
#        postgresql-contrib-$POSTGRES_VERSION postgresql-server-dev-$POSTGRES_VERSION

#not installing postgres server, so manually create user
sudo useradd postgres -m -s /bin/bash
#RUN groupadd postgres
sudo usermod -a -G postgres postgres

sudo mkdir /installs
pushd /installs
wget --quiet http://www.pgpool.net/download.php?f=pgpool-II-$PGPOOL_VERSION.tar.gz -O pgpool-II-$PGPOOL_VERSION.tar.gz
tar -xvf pgpool-II-$PGPOOL_VERSION.tar.gz && \
pushd pgpool-II-$PGPOOL_VERSION 
./configure && make && sudo make install

sudo mkdir -p -m 700 /etc/pgpool2 && chown -R postgres:postgres /etc/pgpool2
sudo mkdir -p -m 755 /var/log/pgpool && chown -R postgres:postgres /var/log/pgpool
sudo chmod 755 /etc/init.d/pgpool

#USER postgres
sudo chown -R postgres:postgres /etc/pgpool2 && \
    sudo mkdir -p /var/run/pgpool && \
    sudo chown -R postgres:postgres /var/run/pgpool && \
    sudo mkdir -p /var/run/postgresql/ && \
    sudo chown -R postgres:postgres  /var/run/postgresql/

#Fix locale warnings when starting postgres
sudo locale-gen en_US.UTF-8
sudo dpkg-reconfigure locales

