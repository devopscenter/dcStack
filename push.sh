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
sudo docker push  "devopscenter/python:${devops_version}" 
sudo docker push  "devopscenter/python-apache:${devops_version}"
sudo docker push  "devopscenter/python-apache-pgpool:${devops_version}"
sudo docker push  "devopscenter/python-apache-pgpool-redis:${devops_version}"
sudo docker push  "devopscenter/db_postgres:${devops_version}" 
sudo docker push  "devopscenter/db_postgres-standby:${devops_version}"
sudo docker push  "devopscenter/db_postgres-perf-analysis:${devops_version}" 
sudo docker push  "devopscenter/worker_django-rq:${devops_version}" 
sudo docker push  "devopscenter/worker_celery:${devops_version}" 
sudo docker push  "devopscenter/monitor_papertrail:${devops_version}"

sudo docker push  "devopscenter/0099ff.web2:${devops_version}"
sudo docker push  "devopscenter/0099ff.worker2:${devops_version}"

sudo docker push  "devopscenter/66ccff.web:${devops_version}"
