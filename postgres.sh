#!/bin/bash -e

. ./setup.sh

docker build --rm -t "devopscenter/db_postgres:${devops_version}" db/postgres
docker build --rm -t "devopscenter/db_postgres-standby:${devops_version}" db/postgres-standby
docker build --rm -t "devopscenter/db_postgres-repmgr:${devops_version}" db/postgres-repmgr
