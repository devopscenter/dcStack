#!/bin/bash -e

source VERSION
echo "Version=${devops_version}"
sudo docker push  "devopscenter/python:${devops_version}" 
sudo docker push  "devopscenter/web_apache:${devops_version}"
sudo docker push  "devopscenter/db_postgres:${devops_version}" 
sudo docker push  "devopscenter/db_postgres-perf-analysis:${devops_version}" 
sudo docker push  "devopscenter/worker_django-rq:${devops_version}" 
sudo docker push  "devopscenter/worker_celery:${devops_version}" 
