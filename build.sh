#!/bin/bash -e
docker build -rm -t "devopscenter/web" web
docker build -rm -t "devopscenter/db" db
docker build -rm -t "devopscenter/worker" worker
