#!/bin/bash -e

source VERSION
echo "Version=${devops_version}"
docker build -rm -t "devopscenter/python:${devops_version}" python
docker build -rm -t "devopscenter/web_apache:${devops_version}" web/apache
docker build -rm -t "devopscenter/db_postgres:${devops_version}" db/postgres
docker build -rm -t "devopscenter/db_postgres-perf-analysis:${devops_version}" db/postgres-performance-analysis
docker build -rm -t "devopscenter/worker_django-rq:${devops_version}" worker/django-rq
docker build -rm -t "devopscenter/worker_celery:${devops_version}" worker/celery
