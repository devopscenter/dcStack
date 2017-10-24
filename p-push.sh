#!/usr/bin/env bash
#===============================================================================
#
#          FILE: p-push.sh
#
#         USAGE: p-push.sh
#
#   DESCRIPTION: Docker Stack - Docker stack to manage infrastructures
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

source VERSION
echo "Version=${dcSTACK_VERSION}"

function buildtools {
    docker push  "devopscenter/jenkins:${dcSTACK_VERSION}" &
}

function base {
    docker push  "devopscenter/base:${dcSTACK_VERSION}"
}

function db {
    docker push  "devopscenter/db_base:${dcSTACK_VERSION}"
    docker push  "devopscenter/db_postgres:${dcSTACK_VERSION}"  
    docker push  "devopscenter/db_postgres-standby:${dcSTACK_VERSION}"
    docker push  "devopscenter/db_postgres-repmgr:${dcSTACK_VERSION}"
#   docker push  "devopscenter/db_postgres-restore:${dcSTACK_VERSION}"
    docker push  "devopscenter/db_redis:${dcSTACK_VERSION}"
    docker push  "devopscenter/db_redis-standby:${dcSTACK_VERSION}"
}

function misc {
    docker push  "devopscenter/syslog:${dcSTACK_VERSION}"
    docker push  "devopscenter/monitor_papertrail:${dcSTACK_VERSION}"
    docker push  "devopscenter/monitor_sentry:${dcSTACK_VERSION}"
    docker push  "devopscenter/monitor_nagios:${dcSTACK_VERSION}"
    docker push  "devopscenter/monitor_newrelic:${dcSTACK_VERSION}" 
}

function stack1 {
    docker push  "devopscenter/0099ff.web:${dcSTACK_VERSION}" 
    docker push  "devopscenter/0099ff.worker:${dcSTACK_VERSION}" 
}

function stack2 {
    docker push  "devopscenter/66ccff.web:${dcSTACK_VERSION}" 
    docker push  "devopscenter/66ccff.worker:${dcSTACK_VERSION}" 
}

function stack3 {
    docker push  "devopscenter/007acc.web:${dcSTACK_VERSION}"
    docker push  "devopscenter/007acc.worker:${dcSTACK_VERSION}"
}
function web {
    docker push  "devopscenter/python:${dcSTACK_VERSION}"
    docker push  "devopscenter/python-nginx:${dcSTACK_VERSION}"
    docker push  "devopscenter/python-nginx-pgpool:${dcSTACK_VERSION}"
    docker push  "devopscenter/python-nginx-pgpool-redis:${dcSTACK_VERSION}"
    rm -rf stack1push.log
    time stack1 &> stack1push.log &
    rm -rf stack2push.log
    time stack2 &> stack2push.log &
    rm -rf stack3push.log
    time stack3 &> stack3push.log &
}

base
time buildtools &> buildtoolspush.log &
time misc &> miscpush.log &
time web &> webpush.log &
time db &> dbpush.log &
