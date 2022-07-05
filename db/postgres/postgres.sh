#!/usr/bin/env bash
#===============================================================================
#
#          FILE: postgres.sh
#
#         USAGE: postgres.sh
#
#   DESCRIPTION: install postgres, python and other utilities needed.
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#                Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 11/21/2016 15:13:37
#      REVISION:  ---
#
# Copyright 2014-2019 devops.center llc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#===============================================================================

#set -o nounset     # Treat unset variables as an error
set -o errexit      # exit immediately if command exits with a non-zero status
set -x             # essentially debug mode
set -o verbose

PGVERSION=$1
DATABASE=$2
VPC_CIDR=$3

. ./postgresenv.sh $PGVERSION

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``${POSTGRES_VERSION}``.
sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main"

sudo apt-get -qq update

echo "installing postgres ver: ${POSTGRES_VERSION}"
sudo apt-get -y -qq install postgresql-${POSTGRES_VERSION} postgresql-client-${POSTGRES_VERSION} postgresql-contrib-${POSTGRES_VERSION} postgresql-server-dev-${POSTGRES_VERSION} libpq5 libpq-dev postgresql-${POSTGRES_VERSION}-postgis-2.2

#Fix locale warnings when starting postgres
sudo locale-gen en_US.UTF-8 && \
    sudo dpkg-reconfigure --frontend=noninteractive locales

#echo "installing wal-e"
#sudo apt-get -qq -y install libffi-dev
#sudo -H pip install -U six

# wal-e v1 and later now require python3
#sudo -H pip install boto
#sudo -H pip install wal-e

sudo apt-get -qq install -y daemontools lzop
sudo -H pip install -U requests

echo "mkdir /media/data/postgres"
sudo mkdir -p ${POSTGRESDBDIR}
sudo mkdir -p /media/data/postgres/${PGLOGS}/transactions
sudo chown -R postgres:postgres /media/data/postgres

sudo chown -R postgres:postgres /var/lib/postgresql


echo "calling config.sh"
sudo su -c "./config.sh ${POSTGRES_VERSION} ${DATABASE} ${VPC_CIDR} " -s /bin/bash postgres

echo "calling pglogs.sh and supervisorconfig"
./pglogs.sh $POSTGRES_VERSION
./supervisorconfig.sh $POSTGRES_VERSION

# stop the systemd postgresql so that it can be disabled and removed
sudo service postgresql stop

#disable init.d autostart
sudo update-rc.d postgresql disable

sudo -H pip install s3cmd

# Create a couple of standard temp directories
sudo mkdir -p /media/data/tmp
sudo chmod 777 /media/data/tmp
sudo mkdir -p /media/data/db_restore
sudo chmod 777 /media/data/db_restore
