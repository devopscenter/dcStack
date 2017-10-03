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
echo "Version=${dcSTACK_VERSION}"
source BASEIMAGE
echo "BaseImage=${baseimageversion}"

#replace variable dcSTACK_VERSION with the VERSION we are building
find . -name "Dockerfile" -type f -print -exec sed -i -e "s/dcSTACK_VERSION/$dcSTACK_VERSION/g" {} \;
find . -name "Dockerfile" -type f -print -exec sed -i -e "s~baseimageversion~$baseimageversion~g" {} \;

#build containers

function base {
    docker build --rm -t "devopscenter/base:${dcSTACK_VERSION}" .
}

function db {
    docker build --rm -t "devopscenter/db_base:${dcSTACK_VERSION}" db
    docker build --rm -t "devopscenter/db_postgres:${dcSTACK_VERSION}" db/postgres
    docker build --rm -t "devopscenter/db_postgres-standby:${dcSTACK_VERSION}" db/postgres-standby
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
    mkdir -p 000000-stack/web/wheelhouse
    cp ${PWD}/buildtools/pythonwheel/wheelhouse/* 000000-stack/web/wheelhouse
    docker build --rm -t "devopscenter/000000.web:${dcSTACK_VERSION}" 000000-stack/web
    docker build --rm -t "devopscenter/000000.web-debug:${dcSTACK_VERSION}" 000000-stack/web-debug
    docker build --rm -t "devopscenter/000000.worker:${dcSTACK_VERSION}" 000000-stack/worker
}

function stack1 {
    mkdir -p 0099ff-stack/web/wheelhouse
    cp ${PWD}/buildtools/pythonwheel/wheelhouse/* 0099ff-stack/web/wheelhouse
    docker build --rm -t "devopscenter/0099ff.web:${dcSTACK_VERSION}" 0099ff-stack/web
    docker build --rm -t "devopscenter/0099ff.web-debug:${dcSTACK_VERSION}" 0099ff-stack/web-debug
    docker build --rm -t "devopscenter/0099ff.worker:${dcSTACK_VERSION}" 0099ff-stack/worker
}

function stack2 {
    mkdir -p 66ccff-stack/web/wheelhouse 
    cp ${PWD}/buildtools/pythonwheel/wheelhouse/* 66ccff-stack/web/wheelhouse
    docker build --rm -t "devopscenter/66ccff.web:${dcSTACK_VERSION}" 66ccff-stack/web
    docker build --rm -t "devopscenter/66ccff.worker:${dcSTACK_VERSION}" 66ccff-stack/worker
}

function stack3 {
    mkdir -p 007acc-stack/web/wheelhouse
    cp ${PWD}/buildtools/pythonwheel/wheelhouse/* 007acc-stack/web/wheelhouse
    docker build --rm -t "devopscenter/007acc.web:${dcSTACK_VERSION}" 007acc-stack/web
    docker build --rm -t "devopscenter/007acc.worker:${dcSTACK_VERSION}" 007acc-stack/worker
}

function stack4 {
    mkdir -p 9900af-stack/web/wheelhouse
    cp ${PWD}/buildtools/pythonwheel/wheelhouse/* 9900af-stack/web/wheelhouse
    docker build --rm -t "devopscenter/9900af.web:${dcSTACK_VERSION}" 9900af-stack/web
    docker build --rm -t "devopscenter/9900af.worker:${dcSTACK_VERSION}" 9900af-stack/worker
}

function stack5 {
    mkdir -p ab0000-stack/web/wheelhouse
    cp ${PWD}/buildtools/pythonwheel/wheelhouse/* ab0000-stack/web/wheelhouse
    docker build --rm -t "devopscenter/ab0000.web:${dcSTACK_VERSION}" ab0000-stack/web
}

function buildtools {
    echo "Running buildtools"
    # this may not be needed since we have an app stack that builds a jenkins image
    #docker build --rm -t "devopscenter/jenkins:${dcSTACK_VERSION}" buildtools/jenkins &> jenkins.log &
#
# Build all packages for specific stacks as wheels, to be shared when building the containers for the specific stacks
#
    mkdir -p buildtools/pythonwheel/wheelhouse
    docker build --rm -t "devopscenter/buildtools:${dcSTACK_VERSION}" buildtools/pythonwheel
    rm -rf buildtools/pythonwheel/application/app*
    mkdir -p buildtools/pythonwheel/application
    cp 000000-stack/web/requirements.txt buildtools/pythonwheel/application/app0.requirements.txt
    cp 0099ff-stack/web/requirements.txt buildtools/pythonwheel/application/app1.requirements.txt
    cp 66ccff-stack/web/requirements.txt buildtools/pythonwheel/application/app2.requirements.txt
    cp 007acc-stack/web/requirements.txt buildtools/pythonwheel/application/app3.requirements.txt
    cp ab0000-stack/web/requirements.txt buildtools/pythonwheel/application/app4.requirements.txt
    docker run --rm \
        -v "${PWD}/buildtools/pythonwheel/application":/application \
        -v "${PWD}/buildtools/pythonwheel/wheelhouse":/wheelhouse \
        "devopscenter/buildtools:${dcSTACK_VERSION}"
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
    buildtools &> buildtools.log

# remove numpy and pandas wheels, which have strange dependencies between different builds.
    rm buildtools/pythonwheel/wheelhouse/numpy*.*
    rm buildtools/pythonwheel/wheelhouse/pandas*.*


    echo "built all wheels for specific stacks"
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
}

base > base.log 
time misc &> misc.log &
time web &> web.log &
time db &> db.log &
