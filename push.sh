#!/bin/bash -e

source VERSION
echo "Version=${devops_version}"
sudo docker push  "devopscenter/python:${devops_version}" 
sudo docker push  "devopscenter/python-apache:${devops_version}"
sudo docker push  "devopscenter/python-apache-pgpool:${devops_version}"
sudo docker push  "devopscenter/python-apache-pgpool-redis:${devops_version}"
sudo docker push  "devopscenter/db_postgres:${devops_version}" 
sudo docker push  "devopscenter/db_postgres-perf-analysis:${devops_version}" 
sudo docker push  "devopscenter/worker_django-rq:${devops_version}" 
sudo docker push  "devopscenter/worker_celery:${devops_version}" 

sudo docker push  "devopscenter/0099ff.web:${devops_version}"
sudo docker push  "devopscenter/0099ff.worker:${devops_version}"

sudo docker push  "devopscenter/66ccff.web:${devops_version}"

