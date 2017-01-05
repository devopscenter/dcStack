#!/bin/bash -e

. ./setup.sh

docker build --rm -t "devopscenter/db_postgres:${dcSTACK_VERSION}" db/postgres
docker build --rm -t "devopscenter/db_postgres-standby:${dcSTACK_VERSION}" db/postgres-standby
docker build --rm -t "devopscenter/db_postgres-repmgr:${dcSTACK_VERSION}" db/postgres-repmgr
