#!/bin/bash -e
docker build -rm -t "devopscenter/python" python
docker build -rm -t "devopscenter/web_apache" web/apache
docker build -rm -t "devopscenter/db_postgres" db/postgres
docker build -rm -t "devopscenter/db_postgres-performance-analysis" db/postgres-performance-analysis
docker build -rm -t "devopscenter/worker_django-rq" worker/django-rq
docker build -rm -t "devopscenter/worker_celery" worker/celery
