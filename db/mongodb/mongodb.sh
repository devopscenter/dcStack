#!/usr/bin/env bash
#===============================================================================
#
#          FILE: mongo.sh
#
#         USAGE: mongo.sh
#
#   DESCRIPTION: install mongo, python and other utilities needed.
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
# Copyright 2014-2017 devops.center llc
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

MONGO_VERSION=$1
DATABASE=$2
VPC_CIDR=$3

. ./mongoenv.sh $MONGO_VERSION

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
sudo pip3 install --upgrade pip

pushd /tmp
sudo wget --quiet https://bootstrap.pypa.io/get-pip.py && sudo python get-pip.py
popd

# INSTALL mongodb =====

# Add the mongoQL PGP key to verify their Debian packages.
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5

# create the list file for mongo so that it can be installed
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/${MONGO_VERSION} multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-${MONGO_VERSION}.list

sudo apt-fast -qq update

echo "installing mongo ver: ${mongo_VERSION}"
sudo apt-get install -y mongodb-org=${MONGO_VERSION} mongodb-org-server=${MONGO_VERSION} mongodb-org-shell=${MONGO_VERSION} mongodb-org-mongos=${MONGO_VERSION} mongodb-org-tools=${MONGO_VERSION}


echo "pinning the packages at tha version: ${MONGO_VERSION}"
echo "mongodb-org hold" | sudo dpkg --set-selections
echo "mongodb-org-server hold" | sudo dpkg --set-selections
echo "mongodb-org-shell hold" | sudo dpkg --set-selections
echo "mongodb-org-mongos hold" | sudo dpkg --set-selections
echo "mongodb-org-tools hold" | sudo dpkg --set-selections


echo "mkdir /media/data/mongo"
sudo mkdir -p ${MONGODBDIR}
sudo chown -R mongodb:mongodb /media/data/mongo

sudo chown -R mongodb:mongodb /var/lib/mongodb
sudo chown -R mongodb:mongodb /var/log/mongodb

# TODO...start here

#echo "calling config.sh"
#sudo su -c "./config.sh ${mongo_VERSION} ${DATABASE} ${VPC_CIDR} " -s /bin/sh mongo

#echo calling xlog.sh and supervisorconfig
#./xlog.sh $mongo_VERSION
echo calling supervisorconfig
./supervisorconfig.sh $mongo_VERSION

# stop the systemd mongoql so that it can be disabled and removed
sudo service mongod stop

#disable init.d autostart
sudo update-rc.d mongod disable
# and finally remove it
#sudo update-rc.d mongoql remove

sudo pip install s3cmd==1.6.1
sudo pip install -U setuptools

# Create a couple of standard temp directories
sudo mkdir -p /media/data/tmp
sudo chmod 777 /media/data/tmp
sudo mkdir -p /media/data/db_restore
sudo chmod 777 /media/data/db_restore
