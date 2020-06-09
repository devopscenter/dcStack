#!/usr/bin/env bash
#===============================================================================
#
#          FILE: mongodbenv.sh
#
#         USAGE: mongodbenv.sh
#
#   DESCRIPTION: set the variables that will assist with installing and starting
#                mongodb
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
set -o verbose

MONGODBVERSION=$1

# default mongodb version to install
MONGODB_VERSION=4.2

# If the version number is specified, then override the default version number.
if [ -n "$MONGODBVERSION" ]; then
  MONGODB_VERSION=${MONGODBVERSION}
fi

echo "mongoversion: "+${MONGODBVERSION} "mongo_version: "+${MONGODB_VERSION}

MONGODB_MOUNT=/media/data/mongodb
#
MONGODBDIR=${MONGODB_MOUNT}/db
#POSTGRESBINDIR=/usr/lib/postgresql/${POSTGRES_VERSION}/bin
#POSTGREX_XLOG=${POSTGRES_MOUNT}/xlog/transactions
#
#POSTGRES_CONF=${POSTGRESDBDIR}/postgresql.conf
#POSTGRES_PERF_CONF=${POSTGRESDBDIR}/postgresql.conf.perf
#POSTGRES_WALE_CONF=${POSTGRESDBDIR}/postgresql.conf.wale
