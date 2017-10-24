#!/usr/bin/env bash
#===============================================================================
#
#          FILE: upgrade.sh
#
#         USAGE: upgrade.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#                Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 11/21/2016 15:13:37
#      REVISION:  ---
#
# Copyright 2014-2017 devops.center llc
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
#===============================================================================

#set -o nounset     # Treat unset variables as an error
#set -o errexit      # exit immediately if command exits with a non-zero status
#set -x             # essentially debug mode

rm -rf /var/lib/postgresql/9.4/main/*
/usr/lib/postgresql/9.4/bin/initdb --locale en_US.UTF-8 -D /var/lib/postgresql/9.4/main
cp /etc/postgresql/9.4/main/postgresql.conf /var/lib/postgresql/9.4/main/postgresql.conf
/usr/lib/postgresql/9.4/bin/pg_upgrade  -b /usr/lib/postgresql/9.3/bin -B /usr/lib/postgresql/9.4/bin -d /tmp/postgres/restore9.3 -D /var/lib/postgresql/9.4/main
