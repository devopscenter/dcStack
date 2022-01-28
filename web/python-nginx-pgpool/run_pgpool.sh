#!/usr/bin/env bash
#===============================================================================
#
#          FILE: run_pgpool.sh
#
#         USAGE: run_pgpool.sh
#
#   DESCRIPTION: This script is run by Supervisor to start pgpool in foreground mode
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
# Copyright 2014-2021 devops.center llc
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


# Create the socket directories, if it doesn't already exist.
 
if [ ! -d /var/run/pgpool ]; then
  sudo install -d -m 755 -o postgres -g postgres /var/run/pgpool
fi
if [ ! -d /var/run/postgresql ]; then
  sudo install -d -m 755 -o postgres -g postgres /var/run/postgresql
fi
# Make sure that pgpool does not read in any pre-existing status file, so that it will query backends on startup
# to see whether they are reachable or not. This is the preferred beahvior, UNLESS the pgpool config permits pgpool
# to initiate postgres follower promotions.

exec /usr/local/bin/pgpool -a /etc/pgpool2/pool_hba.conf -f $1 -F /etc/pgpool2/pcp.conf -n -D

