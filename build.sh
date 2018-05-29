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
echo "Postgresql version=${postgreVerison}"

#replace variable dcSTACK_VERSION with the VERSION we are building
find . -name "Dockerfile" -type f -print -exec sed -i -e "s/dcSTACK_VERSION/$dcSTACK_VERSION/g" {} \;
find . -name "Dockerfile" -type f -print -exec sed -i -e "s~baseimageversion~$baseimageversion~g" {} \;
find . -name "Dockerfile" -type f -print -exec sed -i -e "s/ENV POSTGRES_VERSION .*/ENV POSTGRES_VERSION $postgresVersion/g" {} \;
sed -i -e "s/^POSTGRES_VERSION=.*/POSTGRES_VERSION=$postgresVersion/" db/postgres/postgresenv.sh
sed -i -e "s/^POSTGRES_VERSION=.*/POSTGRES_VERSION=$postgresVersion/" web/python-nginx-pgpool/pgpoolenv.sh

#build containers

function base {
    docker build --rm -t "devopscenter/base:${dcSTACK_VERSION}" .
}

function db {
    docker build --rm -t "devopscenter/db_base:${dcSTACK_VERSION}" db
    docker build --rm -t "devopscenter/db_postgres:${dcSTACK_VERSION}" db/postgres
#    docker build --rm -t "devopscenter/db_postgres-standby:${dcSTACK_VERSION}" db/postgres-standby
#   docker build --rm -t "devopscenter/db_postgres-repmgr:${dcSTACK_VERSION}" db/postgres-repmgr
#   docker build --rm -t "devopscenter/db_postgres-restore:${dcSTACK_VERSION}" db/postgres-restore
    docker build --rm -t "devopscenter/db_redis:${dcSTACK_VERSION}" db/redis
    docker build --rm -t "devopscenter/db_redis-standby:${dcSTACK_VERSION}" db/redis-standby
}

function misc {
    docker build --rm -t "devopscenter/syslog:${dcSTACK_VERSION}" logging/. &> syslog.log &
    docker build --rm -t "devopscenter/monitor_papertrail:${dcSTACK_VERSION}" monitor/papertrail &> papertrail.log &
    docker build --rm -t "devopscenter/monitor_sentry:${dcSTACK_VERSION}" monitor/sentry &> sentry.log &
    docker build --rm -t "devopscenter/monitor_nagios:${dcSTACK_VERSION}" monitor/nagios &> nagios.log &
}
# docker build --rm -t "devopscenter/loadbalancer_ssl-termination:${dcSTACK_VERSION}" loadbalancer/ssl-termination
# docker build --rm -t "devopscenter/loadbalancer_haproxy:${dcSTACK_VERSION}" loadbalancer/haproxy

function newrelic {
    docker build --rm -t "devopscenter/monitor_newrelic:${dcSTACK_VERSION}" monitor/newrelic &
}

function backups {
    docker build --rm -t "devopscenter/db_postgres-backup:${dcSTACK_VERSION}" db/postgres-backup
}

function stack0 {
    docker build --rm -t "devopscenter/000000.web:${dcSTACK_VERSION}" 000000-stack/web
    docker build --rm -t "devopscenter/000000.web-debug:${dcSTACK_VERSION}" 000000-stack/web-debug
    docker build --rm -t "devopscenter/000000.worker:${dcSTACK_VERSION}" 000000-stack/worker
}

function stack1 {
    docker build --rm -t "devopscenter/0099ff.web:${dcSTACK_VERSION}" 0099ff-stack/web
    docker build --rm -t "devopscenter/0099ff.web-debug:${dcSTACK_VERSION}" 0099ff-stack/web-debug
    docker build --rm -t "devopscenter/0099ff.worker:${dcSTACK_VERSION}" 0099ff-stack/worker
}

function stack2 {
    docker build --rm -t "devopscenter/66ccff.web:${dcSTACK_VERSION}" 66ccff-stack/web
    docker build --rm -t "devopscenter/66ccff.worker:${dcSTACK_VERSION}" 66ccff-stack/worker
}

function stack3 {
    docker build --rm -t "devopscenter/007acc.web:${dcSTACK_VERSION}" 007acc-stack/web
    docker build --rm -t "devopscenter/007acc.worker:${dcSTACK_VERSION}" 007acc-stack/worker
}

function stack4 {
    docker build --rm -t "devopscenter/9900af.web:${dcSTACK_VERSION}" 9900af-stack/web
    docker build --rm -t "devopscenter/9900af.worker:${dcSTACK_VERSION}" 9900af-stack/worker
}

function stack5 {
    docker build --rm -t "devopscenter/ab0000.web:${dcSTACK_VERSION}" ab0000-stack/web
}

function stack6 {
    docker build --rm -t "devopscenter/765ae2.web:${dcSTACK_VERSION}" 765ae2-stack/web
}

function web {
    docker build --rm -t "devopscenter/python:${dcSTACK_VERSION}" python
    time newrelic &> newrelic.log &
    time backups &> backups.log &
    docker build --rm -t "devopscenter/python-nginx:${dcSTACK_VERSION}" web/python-nginx
    docker build --rm -t "devopscenter/python-nginx-pgpool:${dcSTACK_VERSION}" web/python-nginx-pgpool
    docker build --rm -t "devopscenter/python-nginx-pgpool-redis:${dcSTACK_VERSION}" web/python-nginx-pgpool-redis
#    docker build --rm -t "devopscenter/python-nginx-pgpool-libsodium:${dcSTACK_VERSION}" web/python-nginx-pgpool-libsodium
    echo "built common containers"
}

function web-all {
    docker build --rm -t "devopscenter/python:${dcSTACK_VERSION}" python
    time newrelic &> newrelic.log &
    time backups &> backups.log &
    docker build --rm -t "devopscenter/python-nginx:${dcSTACK_VERSION}" web/python-nginx
    docker build --rm -t "devopscenter/python-nginx-pgpool:${dcSTACK_VERSION}" web/python-nginx-pgpool
    docker build --rm -t "devopscenter/python-nginx-pgpool-redis:${dcSTACK_VERSION}" web/python-nginx-pgpool-redis
#    docker build --rm -t "devopscenter/python-nginx-pgpool-libsodium:${dcSTACK_VERSION}" web/python-nginx-pgpool-libsodium
    echo "built common containers"


    rm -rf stack0.log
    time stack0 &> stack0.log &
    rm -rf stack1.log
    time stack1 &> stack1.log &
    rm -rf stack2.log
    time stack2 &> stack2.log &
    rm -rf stack3.log
    time stack3 &> stack3.log &
    rm -rf stack4.log
    time stack4 &> stack4.log &
    rm -rf stack5.log
    time stack5 &> stack5.log &
    rm -rf stack6.log
    time stack6 &> stack6.log &
}

if [[ $# -gt 0 ]]; then
    ${1} > ${1}.log
else
    base > base.log 
    time misc &> misc.log &
    time web-all &> web.log &
    time db &> db.log &
fi
