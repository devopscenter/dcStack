#!/bin/bash
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

supervisorctl stop postgres
rm -rf /media/data/postgres/db/*
#ln -s /media/data/postgres/xlog /media/data/postgres/db/pg_xlog
#sudo chown -R postgres:postgres /media/data/postgres/xlog
pg_basebackup -D /media/data/postgres/db -w -R --xlog-method=stream --dbname="host=masterdb_1 user=postgres"
chown -R postgres:postgres /media/data/postgres/db
supervisorctl start postgres
