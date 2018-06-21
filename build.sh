#!/usr/bin/env bash
#===============================================================================
#
#          FILE: drop-index.sh
#
#         USAGE: ./drop-index.sh
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
#set -o verbose     # print the shell lines as they are executed
set -x             # essentially debug mode

source VERSION
echo "Version=${dcSTACK_VERSION}"
source BASEIMAGE
echo "BaseImage=${baseimageversion}"
source POSTGRES_VERSION
echo "Postgresql version=${postgresVerison}"

COMPOSITE_TAG=${dcSTACK_VERSION}-postgres${postgresVersion}

#build containers

function base {
    docker build --rm --build-arg baseimageversion=${baseimageversion} -t "devopscenter/base:${COMPOSITE_TAG}" .
}

function db {
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} --build-arg POSTGRES_VERSION=${postgresVersion} -t "devopscenter/db_base:${COMPOSITE_TAG}" db
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} --build-arg POSTGRES_VERSION=${postgresVersion} -t "devopscenter/db_postgres:${COMPOSITE_TAG}" db/postgres
#    docker build --rm -t "devopscenter/db_postgres-standby:${COMPOSITE_TAG}" db/postgres-standby
#   docker build --rm -t "devopscenter/db_postgres-repmgr:${COMPOSITE_TAG}" db/postgres-repmgr
#   docker build --rm -t "devopscenter/db_postgres-restore:${COMPOSITE_TAG}" db/postgres-restore
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/db_redis:${COMPOSITE_TAG}" db/redis
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/db_redis-standby:${COMPOSITE_TAG}" db/redis-standby
}

function misc {
    docker build --rm --build-arg baseimageversion=${baseimageversion} -t "devopscenter/syslog:${COMPOSITE_TAG}" logging/. &> syslog.log &
    docker build --rm --build-arg baseimageversion=${baseimageversion} -t "devopscenter/monitor_papertrail:${COMPOSITE_TAG}" monitor/papertrail &> papertrail.log &
    docker build --rm -t "devopscenter/monitor_sentry:${COMPOSITE_TAG}" monitor/sentry &> sentry.log &
    docker build --rm -t "devopscenter/monitor_nagios:${COMPOSITE_TAG}" monitor/nagios &> nagios.log &
}
# docker build --rm -t "devopscenter/loadbalancer_ssl-termination:${COMPOSITE_TAG}" loadbalancer/ssl-termination
# docker build --rm -t "devopscenter/loadbalancer_haproxy:${COMPOSITE_TAG}" loadbalancer/haproxy

function newrelic {
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} --build-arg POSTGRES_VERSION=${postgresVersion} -t "devopscenter/monitor_newrelic:${COMPOSITE_TAG}" monitor/newrelic &
}

function backups {
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/db_postgres-backup:${COMPOSITE_TAG}" db/postgres-backup
}

function stack0 {
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/000000.web:${COMPOSITE_TAG}" 000000-stack/web
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/000000.web-debug:${COMPOSITE_TAG}" 000000-stack/web-debug
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/000000.worker:${COMPOSITE_TAG}" 000000-stack/worker
}

function stack1 {
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/0099ff.web:${COMPOSITE_TAG}" 0099ff-stack/web
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/0099ff.web-debug:${COMPOSITE_TAG}" 0099ff-stack/web-debug
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/0099ff.worker:${COMPOSITE_TAG}" 0099ff-stack/worker
}

function stack2 {
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/66ccff.web:${COMPOSITE_TAG}" 66ccff-stack/web
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/66ccff.worker:${COMPOSITE_TAG}" 66ccff-stack/worker
}

function stack3 {
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/007acc.web:${COMPOSITE_TAG}" 007acc-stack/web
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/007acc.worker:${COMPOSITE_TAG}" 007acc-stack/worker
}

function stack4 {
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/9900af.web:${COMPOSITE_TAG}" 9900af-stack/web
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/9900af.worker:${COMPOSITE_TAG}" 9900af-stack/worker
}

function stack5 {
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/ab0000.web:${COMPOSITE_TAG}" ab0000-stack/web
}

function stack6 {
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/765ae2.web:${COMPOSITE_TAG}" 765ae2-stack/web
}

function web {
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/python:${COMPOSITE_TAG}" python
    time newrelic &> newrelic.log &
    time backups &> backups.log &
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/python-nginx:${COMPOSITE_TAG}" web/python-nginx
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} --build-arg POSTGRES_VERSION=${postgresVersion} -t "devopscenter/python-nginx-pgpool:${COMPOSITE_TAG}" web/python-nginx-pgpool
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} --build-arg POSTGRES_VERSION=${postgresVersion} -t "devopscenter/python-nginx-pgpool-redis:${COMPOSITE_TAG}" web/python-nginx-pgpool-redis
#    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/python-nginx-pgpool-libsodium:${COMPOSITE_TAG}" web/python-nginx-pgpool-libsodium
    echo "built common containers"
}

function web-all {
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/python:${COMPOSITE_TAG}" python
    newrelic &> newrelic.log &
    backups &> backups.log &
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/python-nginx:${COMPOSITE_TAG}" web/python-nginx
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} --build-arg POSTGRES_VERSION=${postgresVersion} -t "devopscenter/python-nginx-pgpool:${COMPOSITE_TAG}" web/python-nginx-pgpool
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} --build-arg POSTGRES_VERSION=${postgresVersion} -t "devopscenter/python-nginx-pgpool-redis:${COMPOSITE_TAG}" web/python-nginx-pgpool-redis
#    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/python-nginx-pgpool-libsodium:${COMPOSITE_TAG}" web/python-nginx-pgpool-libsodium
    echo "built common containers"


    rm -rf stack0.log
    stack0 &> stack0.log
    rm -rf stack1.log
    stack1 &> stack1.log
    rm -rf stack2.log
    stack2 &> stack2.log
    rm -rf stack3.log
    stack3 &> stack3.log
    rm -rf stack4.log
    stack4 &> stack4.log
    rm -rf stack5.log
    stack5 &> stack5.log
    rm -rf stack6.log
    stack6 &> stack6.log
}

if [[ $# -gt 0 ]]; then
    ${1} > ${1}.log
else
    # ORIGINAL flow
    #base > base.log
    #time misc &> misc.log &
    #time web-all &> web.log &
    #time db &> db.log &
    postgresVersion=9.4
    COMPOSITE_TAG=${dcSTACK_VERSION}-postgres${postgresVersion}
    echo  ${COMPOSITE_TAG}
    base > base9.4.log
    misc &> misc9.4.log &
    web-all &> web9.4.log
    db &> db9.4.log
    postgresVersion=9.6
    COMPOSITE_TAG=${dcSTACK_VERSION}-postgres${postgresVersion}
    echo  ${COMPOSITE_TAG}
    base > base9.6.log
    misc &> misc9.6.log &
    web-all &> web9.6.log
    db &> db9.6.log
fi
