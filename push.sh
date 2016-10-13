#!/bin/bash -evx
#
# Docker Stack - Docker stack to manage infrastructures
#
# Copyright 2014 devops.center
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

source VERSION
echo "Version=${devops_version}"

function buildtools {
    docker push  "devopscenter/jenkins:${devops_version}" &
}

function base {
    docker push  "devopscenter/base:${devops_version}"
}

function db {
    docker push  "devopscenter/db_base:${devops_version}"
    docker push  "devopscenter/db_postgres:${devops_version}"  
    docker push  "devopscenter/db_postgres-standby:${devops_version}"
    docker push  "devopscenter/db_postgres-repmgr:${devops_version}"
#   docker push  "devopscenter/db_postgres-restore:${devops_version}"
    docker push  "devopscenter/db_redis:${devops_version}"
    docker push  "devopscenter/db_redis-standby:${devops_version}"
}

function misc {
    docker push  "devopscenter/syslog:${devops_version}"
    docker push  "devopscenter/monitor_papertrail:${devops_version}"
    docker push  "devopscenter/monitor_sentry:${devops_version}"
    docker push  "devopscenter/monitor_nagios:${devops_version}"
    docker push  "devopscenter/monitor_newrelic:${devops_version}" 
}

function stack1 {
    docker push  "devopscenter/0099ff.web:${devops_version}" 
    docker push  "devopscenter/0099ff.worker:${devops_version}" 
}

function stack2 {
    docker push  "devopscenter/66ccff.web:${devops_version}" 
    docker push  "devopscenter/66ccff.worker:${devops_version}" 
}

function stack3 {
    docker push  "devopscenter/007acc.web:${devops_version}"
    docker push  "devopscenter/007acc.worker:${devops_version}"
}
function web {
    docker push  "devopscenter/python:${devops_version}"
    docker push  "devopscenter/python-nginx:${devops_version}"
    docker push  "devopscenter/python-nginx-pgpool:${devops_version}"
    docker push  "devopscenter/python-nginx-pgpool-redis:${devops_version}"
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
ime db &> dbpush.log &
