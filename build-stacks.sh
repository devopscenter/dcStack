#!/usr/bin/env bash
#===============================================================================
#
#          FILE: build.sh
#
#         USAGE: ./build.sh
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
#set -o verbose     # print the shell lines as they are executed
set -x             # essentially debug mode

source VERSION
echo "Version=${dcSTACK_VERSION}"
source BASEIMAGE
echo "BaseImage=${baseimageversion}"
source POSTGRES_VERSION
echo "Postgresql version=${postgresVerison}"
. db/mysql/mysqlenv.sh
echo "MySQL version=${MYSQLDB_VERSION}"

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
}


function backups {
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/db_postgres-backup:${COMPOSITE_TAG}" db/postgres-backup
}


function stack1 {
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/0099ff.web:${COMPOSITE_TAG}" 0099ff-stack/web
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/0099ff.web-debug:${COMPOSITE_TAG}" 0099ff-stack/web-debug
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/0099ff.worker:${COMPOSITE_TAG}" 0099ff-stack/worker
}

function stack6 {
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/765ae2.web:${COMPOSITE_TAG}" 765ae2-stack/web
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/765ae2.svc:${COMPOSITE_TAG}" 765ae2-stack/svc
}


function web {
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/python:${COMPOSITE_TAG}" python
    time backups &> backups.log &
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/python-nginx:${COMPOSITE_TAG}" web/python-nginx
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} --build-arg POSTGRES_VERSION=${postgresVersion} -t "devopscenter/python-nginx-pgpool:${COMPOSITE_TAG}" web/python-nginx-pgpool
    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} --build-arg POSTGRES_VERSION=${postgresVersion} -t "devopscenter/python-nginx-pgpool-redis:${COMPOSITE_TAG}" web/python-nginx-pgpool-redis
#    docker build --rm --build-arg COMPOSITE_TAG=${COMPOSITE_TAG} -t "devopscenter/python-nginx-pgpool-libsodium:${COMPOSITE_TAG}" web/python-nginx-pgpool-libsodium
    echo "built common containers"
}


function stacks {

#    rm -rf stack1.log
#    stack1 &> stack1.log

    rm -rf stack6.log
    stack6 &> stack6.log

}

if [[ $# -gt 0 ]]; then
    ${1} > ${1}.log
else
    postgresVersion=9.6
    COMPOSITE_TAG=${dcSTACK_VERSION}-postgres${postgresVersion}
    echo  ${COMPOSITE_TAG}

    stacks &> web9.6.log

    postgresVersion=10
    COMPOSITE_TAG=${dcSTACK_VERSION}-postgres${postgresVersion}
    echo  ${COMPOSITE_TAG}

    stacks &> web10.log

fi
