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

#replace variable devops_version with the VERSION we are building
find . -name "Dockerfile" -type f -exec sed -i -e "s/devops_version/$devops_version/g" {} \;

#build containers
docker build -rm -t "devopscenter/python:${devops_version}" python
docker build -rm -t "devopscenter/python-apache:${devops_version}" web/python-apache
docker build -rm -t "devopscenter/python-apache-pgpool:${devops_version}" web/python-apache-pgpool
docker build -rm -t "devopscenter/python-apache-pgpool-redis:${devops_version}" web/python-apache-pgpool-redis
docker build -rm -t "devopscenter/db_postgres:${devops_version}" db/postgres
docker build -rm -t "devopscenter/db_postgres-standby:${devops_version}" db/postgres-standby
docker build -rm -t "devopscenter/db_postgres-perf-analysis:${devops_version}" db/postgres-performance-analysis
docker build -rm -t "devopscenter/db_postgres-restore:${devops_version}" db/postgres-restore
docker build -rm -t "devopscenter/monitor_papertrail:${devops_version}" monitor/papertrail
docker build -rm -t "devopscenter/monitor_sentry:${devops_version}" monitor/sentry
#docker build -rm -t "devopscenter/loadbalancer_ssl-termination:${devops_version}" loadbalancer/ssl-termination
#docker build -rm -t "devopscenter/loadbalancer_haproxy:${devops_version}" loadbalancer/haproxy

docker build -rm -t "devopscenter/0099ff.web2:${devops_version}" 0099FF-stack/web
docker build -rm -t "devopscenter/0099ff.worker2:${devops_version}" 0099FF-stack/worker

docker build -rm -t "devopscenter/66ccff.web:${devops_version}" 66CCFF-stack/web
docker build -rm -t "devopscenter/66ccff.worker:${devops_version}" 66CCFF-stack/worker
