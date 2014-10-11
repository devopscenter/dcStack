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

service postgresql stop
#/usr/lib/postgresql/9.3/bin/pg_ctl stop -D /var/lib/postgresql/9.3/main -m immediate
rm -rf /var/lib/postgresql/9.3/main/*
pg_basebackup -D /var/lib/postgresql/9.3/main -w -R --xlog-method=stream --dbname="host=masterdb_1 user=postgres"
chown -R postgres:postgres /var/lib/postgresql/9.3/main
service postgresql start
#/usr/lib/postgresql/9.3/bin/postgres -D /var/lib/postgresql/9.3/main -c config_file=/etc/postgresql/9.3/main/postgresql.conf
