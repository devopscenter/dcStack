#!/usr/bin/env bash
#===============================================================================
#
#          FILE: push.sh 
#
#         USAGE: ./push.sh
#
#   DESCRIPTION: push the dcStack containers to docker hub
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
# NOTE: To do a push you will have to  login to docker up with: docker login
#===============================================================================

#set -o nounset     # Treat unset variables as an error
set -o errexit      # exit immediately if command exits with a non-zero status
set -x             # essentially debug mode
set -o verbose

source VERSION
echo "Version=${dcSTACK_VERSION}"

function base {
    docker push  "devopscenter/base:${COMPOSITE_TAG}"
}

function db {
    docker push  "devopscenter/db_base:${COMPOSITE_TAG}"
    docker push  "devopscenter/db_postgres:${COMPOSITE_TAG}"  
#    docker push  "devopscenter/db_postgres-standby:${COMPOSITE_TAG}"
#    docker push  "devopscenter/db_postgres-repmgr:${COMPOSITE_TAG}"
#   docker push  "devopscenter/db_postgres-restore:${COMPOSITE_TAG}"
    docker push  "devopscenter/db_redis:${COMPOSITE_TAG}"
    docker push  "devopscenter/db_redis-standby:${COMPOSITE_TAG}"
}

function mysql {
    docker push  "devopscenter/db_base:${COMPOSITE_TAG}"
    docker push  "devopscenter/db_mysql:${COMPOSITE_TAG}"
}

function mongodb {
    docker push  "devopscenter/db_base:${COMPOSITE_TAG}"
    docker push  "devopscenter/db_mongodb:${COMPOSITE_TAG}"
}

function misc {
    docker push  "devopscenter/syslog:${COMPOSITE_TAG}"
    docker push  "devopscenter/monitor_papertrail:${COMPOSITE_TAG}"
#    docker push  "devopscenter/monitor_sentry:${COMPOSITE_TAG}"
#    docker push  "devopscenter/monitor_nagios:${COMPOSITE_TAG}"
#    docker push  "devopscenter/monitor_newrelic:${COMPOSITE_TAG}" 
}

function stack0 {
    docker push  "devopscenter/000000.web:${COMPOSITE_TAG}" 
    docker push  "devopscenter/000000.web-debug:${COMPOSITE_TAG}"
    docker push  "devopscenter/000000.worker:${COMPOSITE_TAG}" 
}

function stack1 {
    docker push  "devopscenter/0099ff.web:${COMPOSITE_TAG}" 
    docker push  "devopscenter/0099ff.web-debug:${COMPOSITE_TAG}"
    docker push  "devopscenter/0099ff.worker:${COMPOSITE_TAG}" 
}

function stack2 {
    docker push  "devopscenter/66ccff.web:${COMPOSITE_TAG}" 
    docker push  "devopscenter/66ccff.worker:${COMPOSITE_TAG}" 
}

function stack3 {
    docker push  "devopscenter/007acc.web:${COMPOSITE_TAG}"
    docker push  "devopscenter/007acc.worker:${COMPOSITE_TAG}"
}

function stack4 {
    docker push  "devopscenter/9900af.web:${COMPOSITE_TAG}"
    docker push  "devopscenter/9900af.worker:${COMPOSITE_TAG}"
}

function stack5 {
    docker push  "devopscenter/ab0000.web:${COMPOSITE_TAG}"
}

function stack6 {
    docker push  "devopscenter/765ae2.web:${COMPOSITE_TAG}"
}

function stack7 {
    docker push  "devopscenter/386dd0.web:${COMPOSITE_TAG}"
    docker push  "devopscenter/386dd0.worker:${COMPOSITE_TAG}"
}

function stack8 {
    # dcMonitoring
    docker push   "devopscenter/1213d64.web:${COMPOSITE_TAG}"
}

function python {
    docker push  "devopscenter/python:${COMPOSITE_TAG}"
    docker push  "devopscenter/python-nginx:${COMPOSITE_TAG}"
    docker push  "devopscenter/python-nginx-pgpool:${COMPOSITE_TAG}"
    docker push  "devopscenter/python-nginx-pgpool-redis:${COMPOSITE_TAG}"
}

function web {
    python
    rm -rf stack0push.log
    time stack0 &> stack0push.log &
    rm -rf stack1push.log
    time stack1 &> stack1push.log &
    rm -rf stack2push.log
    time stack2 &> stack2push.log &
    rm -rf stack3push.log
    time stack3 &> stack3push.log &
    rm -rf stack4push.log
    time stack4 &> stack4push.log &
    rm -rf stack5push.log
    time stack5 &> stack5push.log &
    rm -rf stack6push.log
    time stack6 &> stack6push.log &
}


# TODO this next part needs to be refactored to be more flexible
postgresVersion=9.4
COMPOSITE_TAG=${dcSTACK_VERSION}-postgres${postgresVersion}
echo  ${COMPOSITE_TAG}

base
misc
web
db

postgresVersion=9.6
COMPOSITE_TAG=${dcSTACK_VERSION}-postgres${postgresVersion}
echo  ${COMPOSITE_TAG}

base
misc
web
db

# build the images associated with mysql
. db/mysql/mysqlenv.sh
COMPOSITE_TAG=${dcSTACK_VERSION}-mysql${MYSQLDB_VERSION}
base
misc
python
mysql
mongodb
stack7