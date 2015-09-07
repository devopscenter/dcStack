#!/bin/bash -e
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
source BASEIMAGE
echo "BaseImage=${baseimageversion}"

#replace variable devops_version with the VERSION we are building
find . -name "Dockerfile" -type f -exec sed -i -e "s/devops_version/$devops_version/g" {} \;
find . -name "Dockerfile" -type f -exec sed -i -e "s~baseimageversion~$baseimageversion~g" {} \;

#build containers

function db {
    #rm -rf postgres.log
    docker build --rm -t "devopscenter/db_postgres:${devops_version}" db/postgres
    docker build --rm -t "devopscenter/db_postgres-standby:${devops_version}" db/postgres-standby
    docker build --rm -t "devopscenter/db_postgres-repmgr:${devops_version}" db/postgres-repmgr
    #docker build --rm -t "devopscenter/db_postgres-restore:${devops_version}" db/postgres-restore
    docker build --rm -t "devopscenter/db_redis:${devops_version}" db/redis
    docker build --rm -t "devopscenter/db_redis-standby:${devops_version}" db/redis-standby
}

function misc {
    docker build --rm -t "devopscenter/monitor_papertrail:${devops_version}" monitor/papertrail &> papertrail.log &
    docker build --rm -t "devopscenter/monitor_sentry:${devops_version}" monitor/sentry &> sentry.log &
    docker build --rm -t "devopscenter/monitor_nagios:${devops_version}" monitor/nagios &> nagios.log &
}
#docker build --rm -t "devopscenter/loadbalancer_ssl-termination:${devops_version}" loadbalancer/ssl-termination
#docker build --rm -t "devopscenter/loadbalancer_haproxy:${devops_version}" loadbalancer/haproxy

function newrelic {
    docker build --rm -t "devopscenter/monitor_newrelic:${devops_version}" monitor/newrelic &
}

function backups {
    docker build --rm -t "devopscenter/db_postgres-backup:${devops_version}" db/postgres-backup
}

function stack1 {
    mkdir -p 0099FF-stack/web/wheelhouse
    cp /data/wheelhouse/* 0099FF-stack/web/wheelhouse
    docker build --rm -t "devopscenter/0099ff.web:${devops_version}" 0099FF-stack/web
    docker build --rm -t "devopscenter/0099ff.worker:${devops_version}" 0099FF-stack/worker
}

function stack2 {
    mkdir -p 66CCFF-stack/web/wheelhouse 
    cp /data/wheelhouse/* 66CCFF-stack/web/wheelhouse
    docker build --rm -t "devopscenter/66ccff.web:${devops_version}" 66CCFF-stack/web
    docker build --rm -t "devopscenter/66ccff.worker:${devops_version}" 66CCFF-stack/worker
}

function stack3 {
    mkdir -p 007acc-stack/web/wheelhouse
    cp /data/wheelhouse/* 007acc-stack/web/wheelhouse
    docker build --rm -t "devopscenter/007acc.web:${devops_version}" 007acc-stack/web
    docker build --rm -t "devopscenter/007acc.worker:${devops_version}" 007acc-stack/worker
}

function buildtools {
    echo "Running buildtools"
    docker build --rm -t "devopscenter/jenkins:${devops_version}" buildtools/jenkins &> jenkins.log &
    mkdir -p buildtools/pythonwheel/wheelhouse
    docker build --rm -t "devopscenter/buildtools:${devops_version}" buildtools/pythonwheel
    rm -rf buildtools/pythonwheel/application/app*
    mkdir -p buildtools/pythonwheel/application
    cp 0099FF-stack/web/requirements.txt buildtools/pythonwheel/application/app1.requirements.txt
    cp 0099FF-stack/web/science.txt buildtools/pythonwheel/application/app1.science.txt
    cp 66CCFF-stack/web/requirements.txt buildtools/pythonwheel/application/app2.requirements.txt
    cp 66CCFF-stack/web/science.txt buildtools/pythonwheel/application/app2.science.txt
    cp 007acc-stack/web/requirements.txt buildtools/pythonwheel/application/app3.requirements.txt
    cp 007acc-stack/web/science.txt buildtools/pythonwheel/application/app3.science.txt
    docker run --rm \
        -v "/home/ubuntu/devopscenter/docker-stack/buildtools/pythonwheel/application":/application \
        -v /data/wheelhouse:/wheelhouse \
        "devopscenter/buildtools:${devops_version}"
}

function web {
    docker build --rm -t "devopscenter/python:${devops_version}" python
    time newrelic &> newrelic.log &
    time backups &> backups.log &
    docker build --rm -t "devopscenter/python-apache:${devops_version}" web/python-apache
    docker build --rm -t "devopscenter/python-apache-pgpool:${devops_version}" web/python-apache-pgpool
    docker build --rm -t "devopscenter/python-apache-pgpool-redis:${devops_version}" web/python-apache-pgpool-redis
    buildtools &> buildtools.log
    rm -rf stack1.log
    time stack1 &> stack1.log &
    rm -rf stack2.log
    time stack2 &> stack2.log &
    rm -rf stack3.log
    time stack3 &> stack3.log &
}

time misc &> misc.log &
web &
time db &> db.log &
