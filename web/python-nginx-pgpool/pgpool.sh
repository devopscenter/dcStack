#!/bin/bash -ex

. ./pgpoolenv.sh

# Optionally over-ride default version of Postgres client

if [[ -n "$1" ]]; then
  POSTGRES_VERSION=$1
fi

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
sudo wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
      sudo apt-key add -

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.4``.
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" | sudo tee --append /etc/apt/sources.list.d/pgdg.list

sudo sudo apt-fast update

sudo sudo apt-fast -y -q install postgresql-client-$POSTGRES_VERSION libpq5 libpq-dev
#        postgresql-contrib-$POSTGRES_VERSION postgresql-server-dev-$POSTGRES_VERSION

# not installing postgres server, so manually create user and group, if needed

getent passwd postgres || sudo useradd postgres -m -s /bin/bash
getent group postgres || sudo groupadd postgres

# Add postgres user to postgres group, if not already in it.
if [[ !$(id -Gn postgres | grep '\bpostgres\b') ]]; then
  sudo usermod -a -G postgres postgres
fi

# Add postgres user to sudo group, if not already in it.
if [[ !$(id -Gn postgres | grep '\bsudo\b') ]]; then
  sudo usermod -a -G sudo postgres
fi
sudo cp sudo-postgres.conf /etc/sudoers.d

sudo mkdir -p /installs
pushd /installs
sudo wget --quiet http://www.pgpool.net/download.php?f=pgpool-II-$PGPOOL_VERSION.tar.gz -O pgpool-II-$PGPOOL_VERSION.tar.gz
sudo tar -xvf pgpool-II-$PGPOOL_VERSION.tar.gz && \
pushd pgpool-II-$PGPOOL_VERSION 
sudo ./configure && sudo make --silent && sudo make --silent install

sudo mkdir -p -m 700 /etc/pgpool2 && sudo chown -R postgres:postgres /etc/pgpool2
sudo mkdir -p -m 755 /var/log/pgpool && sudo chown -R postgres:postgres /var/log/pgpool

#USER postgres
sudo chown -R postgres:postgres /etc/pgpool2

#Fix locale warnings when starting postgres
sudo locale-gen en_US.UTF-8
sudo dpkg-reconfigure locales

popd
popd

sudo cp pgpool/pgpool2.init.d /etc/init.d/pgpool
sudo cp supervisor-pgpool.conf /etc/supervisor/conf.d/pgpool.conf
sudo cp run_pgpool.sh /etc/supervisor/conf.d/run_pgpool.sh

sudo cp pgpool/pool_hba.conf /etc/pgpool2/pool_hba.conf
sudo cp pgpool/pgpool.conf.one /etc/pgpool2/pgpool.conf.one
sudo cp pgpool/pgpool.conf.two /etc/pgpool2/pgpool.conf.two
sudo cp pgpool/pgpool.conf.three /etc/pgpool2/pgpool.conf.three
sudo cp pgpool/pcp.conf /etc/pgpool2/pcp.conf

