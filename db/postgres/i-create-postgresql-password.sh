#!/usr/bin/env bash
#===============================================================================
#
#          FILE: i-create-postgresql-password.sh
# 
#         USAGE: ./i-create-postgresql-password.sh 
# 
#   DESCRIPTION: script to create the postgres password and echo the results
#                at the end so the calling script can catch the value
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#                Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 04/10/2017 15:46:05
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
set -x                # essentially debug mode

PUBLIC_IP=$1
DB_NAME=$2
#-------------------------------------------------------------------------------
# set postgres user password
#-------------------------------------------------------------------------------
PG_PWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
psql -U postgres -c "ALTER USER Postgres WITH PASSWORD '${PG_PWD}' ;"
echo "postgres user password: ${PG_PWD}"
echo "To be used to access the database using the public IP:"
echo "postgres://postgres:${PG_PWD}@${PUBLIC_IP}/${DB_NAME,,}"
