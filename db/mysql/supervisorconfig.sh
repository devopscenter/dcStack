#!/usr/bin/env bash
#===============================================================================
#
#          FILE: supervisorconfig.sh
#
#         USAGE: supervisorconfig.sh
#
#   DESCRIPTION: setup the config files that supervisor will use to start mysql
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

MYSQLDBVERSION=$1
. ./mysqlenv.sh $MYSQLDBVERSION

# Setup supervisor to run MongoDB
sudo cp ./conf/supervisor-mysql.conf /etc/supervisor/conf.d/mysql.conf
sudo cp ./conf/run_mysql.sh /etc/supervisor/conf.d/run_mysql.sh
echo "export MYSQLDB_VERSION=${MYSQLDB_VERSION}"  | sudo tee -a /etc/default/supervisor

# If on an instance, drop a .env file so that this will always be set when ENVs are updated at any point in the future.
if [[ -d "$HOME/.dcConfig/" ]] ; then 
    echo "MYSQLDB_VERSION=${MYSQLDB_VERSION}" >> "$HOME/.dcConfig/instance-mysql.env"
fi
