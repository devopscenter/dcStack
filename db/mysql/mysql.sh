#!/usr/bin/env bash
#===============================================================================
#
#          FILE: mysql.sh
#
#         USAGE: mysql.sh
#
#   DESCRIPTION: install mysql, and other utilities needed.
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
# Copyright 2014-2018 devops.center llc
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
#set -o verbose

MYSQLDB_VERSION=$1
DATABASE=$2
VPC_CIDR=$3

. ./mysqlenv.sh $MYSQLDB_VERSION

sudo apt-get -qq update && sudo apt-get -qq -y install software-properties-common && \
    sudo add-apt-repository "deb http://gb.archive.ubuntu.com/ubuntu $(lsb_release -sc) universe" && \
    sudo apt-get -qq update

sudo apt-get -qq -y install debconf-utils

sudo add-apt-repository -y ppa:saiarcot895/myppa && \
    sudo apt-get -qq update && \
    sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y install apt-fast

sudo apt-fast -qq -y install git wget sudo vim

# INSTALL mysql =====
echo "installing MySQL ver: ${MYSQLDB_VERSION}"
# Install MySQL Server in a Non-Interactive mode. Default root password will be "root"
echo "mysql-server-5.7 mysql-server/root_password password d3vopsc3nt3r" | sudo debconf-set-selections
echo "mysql-server-5.7 mysql-server/root_password_again password d3vopsc3nt3r" | sudo debconf-set-selections
sudo apt-get install -y  mysql-server

# copy over our mysql configuration file
sudo cp conf/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

echo "mkdir ${MYSQLDB_MOUNT}"
# mysql initialization doesn't like that this directory exists prior to the intiialization
#sudo mkdir -p ${MYSQLDB_MOUNT}/db
sudo mkdir -p ${MYSQLDB_MOUNT}/backup
sudo chown -R mysql:mysql ${MYSQLDB_MOUNT}

sudo mkdir -p /var/run/mysqld
sudo mkdir -p /var/lib/mysql
sudo mkdir -p /usr/share/mysql
sudo chown -R mysql:mysql /var/run/mysqld
sudo chown -R mysql:mysql /var/lib/mysql
sudo chown -R mysql:mysql /usr/share/mysql

# initialize mysql
# note disabling this so that mysql can write to the /media/data/mysql directory
sudo service apparmor stop
sudo ln -s /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/
sudo service apparmor restart
sudo aa-status
sudo su -c "mysqld --initialize-insecure" -s /bin/bash mysql

echo calling supervisorconfig
./supervisorconfig.sh $MYSQLDB_VERSION

sudo pip install s3cmd==1.6.1
sudo pip install -U setuptools

# Create a couple of standard temp directories
if [[ ! -d /media/data/tmp ]]; then
    sudo mkdir -p /media/data/tmp
    sudo chmod 777 /media/data/tmp
fi
if [[ ! -d /media/data/db_restore ]]; then
    sudo mkdir -p /media/data/db_restore
    sudo chmod 777 /media/data/db_restore
fi
