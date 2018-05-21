#!/usr/bin/env bash
#===============================================================================
#
#          FILE: run_mongo.sh
#
#         USAGE: run_mongo.sh
#
#   DESCRIPTION: This script is run by Supervisor to start mongodb in foreground mode
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
#set -o errexit      # exit immediately if command exits with a non-zero status
#set -x             # essentially debug mode
 
# This script is run by Supervisor to start mongoQL in foreground mode
 
# example supervisor.conf start commands for mongo
#command=/opt/mongodb/bin/mongod --dbpath /storage/mongodb_data --rest
#command=/usr/bin/mongod --port 27017 --quiet --logpath /var/log/mongodb/mongod.log --logappend

#exec su mongo -c '/usr/lib/mongoql/${mongo_VERSION}/bin/mongo -D /media/data/mongo/db/pgdata -c config_file=/media/data/mongo/db/pgdata/mongoql.conf'
exec su mongodb /usr/bin/mongod --port 27017 --dbpath /media/data/mongo/db

