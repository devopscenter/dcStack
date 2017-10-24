#!/usr/bin/env bash
#===============================================================================
#
#          FILE: run_postgres.sh
#
#         USAGE: run_postgres.sh
#
#   DESCRIPTION: This script is run by Supervisor to start PostgreSQL in foreground mode
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
 
# This script is run by Supervisor to start PostgreSQL in foreground mode
 
if [ -d /var/run/postgresql ]; then
    if [ ! -d /var/run/postgresql/postgres-main.pg_stat_tmp ]; then
        install -d -m 2775 -o postgres -g postgres /var/run/postgresql/postgres-main.pg_stat_tmp
    else
        chmod -R 2775 /var/run/postgresql /var/run/postgresql/postgres-main.pg_stat_tmp
    fi
else
    install -d -m 2775 -o postgres -g postgres /var/run/postgresql
    install -d -m 2775 -o postgres -g postgres /var/run/postgresql/postgres-main.pg_stat_tmp
fi

exec su postgres -c '/usr/lib/postgresql/${POSTGRES_VERSION}/bin/postgres -D /media/data/postgres/db/pgdata -c config_file=/media/data/postgres/db/pgdata/postgresql.conf'

