#!/usr/bin/env bash
#===============================================================================
#
#          FILE: restoredb.sh
#
#         USAGE: restoredb.sh
#
#   DESCRIPTION: restore database within a container
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

docker rm dbdata
RUNNING=$(docker inspect --format="{{ .State.ExitCode }}" dbdata 2> /dev/null)
if [ $? -eq 1 ]; then
    docker run -d -v /tmp/postgres/restore9.3 --name dbdata stack_restoredb echo Data-only container for postgres
fi 

docker rm db1
docker run -w /tmp --volumes-from dbdata -v /var/lib/postgresql/9.4/main --name db1 stack_restoredb /bin/bash -c /scripts/upgrade.sh
