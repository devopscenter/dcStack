#!/usr/bin/env bash
#===============================================================================
#
#          FILE: mongodb.sh
#
#         USAGE: mongodb.sh
#
#   DESCRIPTION: install mongodb, and other utilities needed.
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

MONGODB_VERSION=$1
DATABASE=$2
VPC_CIDR=$3

. ./mongodbenv.sh $MONGODB_VERSION

sudo apt-get -qq update && sudo apt-get -qq -y install software-properties-common && \
    sudo add-apt-repository "deb http://gb.archive.ubuntu.com/ubuntu $(lsb_release -sc) universe" && \
    sudo apt-get -qq update

sudo apt-get -qq -y install debconf-utils

sudo add-apt-repository -y ppa:saiarcot895/myppa && \
    sudo apt-get -qq update && \
    sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y install apt-fast

sudo apt-fast -qq -y install git wget sudo vim

# INSTALL mongodb =====

# Add the MongoDB PGP keys (for 3.4, 3.6 and 4.0) to verify their Debian packages.
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv BC711F9BA15703C6
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4

# create the list file for MongoDB so that it can be installed
echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/${MONGODB_VERSION} multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-${MONGODB_VERSION}.list

#sudo apt-fast -qq update
sudo apt-get -qq update

echo "installing MongoDB ver: ${MONGODB_VERSION}"
#sudo apt-get install -y mongodb-org=${MONGODB_VERSION} mongodb-org-server=${MONGODB_VERSION} mongodb-org-shell=${MONGODB_VERSION} mongodb-org-mongos=${MONGODB_VERSION} mongodb-org-tools=${MONGODB_VERSION}
sudo apt-get install -y  --allow-unauthenticated mongodb-org


echo "pinning the packages at tha version: ${MONGODB_VERSION}"
echo "mongodb-org hold" | sudo dpkg --set-selections
echo "mongodb-org-server hold" | sudo dpkg --set-selections
echo "mongodb-org-shell hold" | sudo dpkg --set-selections
echo "mongodb-org-mongos hold" | sudo dpkg --set-selections
echo "mongodb-org-tools hold" | sudo dpkg --set-selections


echo "mkdir /media/data/mongodb"
sudo mkdir -p ${MONGODBDIR}
sudo chown -R mongodb:mongodb /media/data/mongodb

sudo chown -R mongodb:mongodb /var/lib/mongodb
sudo chown -R mongodb:mongodb /var/log/mongodb

# TODO...start here

#echo "calling config.sh"
#sudo su -c "./config.sh ${MONGODB_VERSION} ${DATABASE} ${VPC_CIDR} " -s /bin/sh mongodb

#echo calling xlog.sh and supervisorconfig
#./xlog.sh $MONGODB_VERSION
echo calling supervisorconfig
./supervisorconfig.sh $MONGODB_VERSION

# stop the systemd mongodb so that it can be disabled and removed
#sudo service mongod stop

#disable init.d autostart
#sudo update-rc.d mongod disable
# and finally remove it
#sudo update-rc.d mongoql remove

sudo pip install s3cmd==1.6.1
sudo pip install -U setuptools

# Create a couple of standard temp directories
sudo mkdir -p /media/data/tmp
sudo chmod 777 /media/data/tmp
sudo mkdir -p /media/data/db_restore
sudo chmod 777 /media/data/db_restore
