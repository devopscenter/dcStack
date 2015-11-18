#!/usr/bin/env bash
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
set -ex
sudo supervisorctl stop postgres
#sudo unlink /media/data/postgres/db/pgdata/pg_xlog
sudo rm -rf /media/data/postgres/db/pgdata/pg_xlog
sudo rm -rf /media/data/postgres/db/pgdata/ /media/data/postgres/db/pg_xlog/ /media/data/postgres/xlog/*
#ln -s /media/data/postgres/xlog /media/data/postgres/db/pg_xlog
#sudo chown -R postgres:postgres /media/data/postgres/xlog
sudo pg_basebackup -D /media/data/postgres/db/pgdata -w -R --xlog-method=stream --dbname="host=postgresmaster_1 user=postgres"
sudo rsync -av /media/data/postgres/db/pgdata/pg_xlog/ /media/data/postgres/xlog
sudo rm -rf /media/data/postgres/db/pgdata/pg_xlog
sudo ln -s /media/data/postgres/xlog/ /media/data/postgres/db/pgdata/pg_xlog
sudo chown -R postgres:postgres /media/data/postgres/db /media/data/postgres/xlog
sudo supervisorctl start postgres
