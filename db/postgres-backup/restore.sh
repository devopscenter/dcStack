#!/usr/bin/env bash
#===============================================================================
#
#          FILE: restore.sh
#
#         USAGE: restore.sh
#
#   DESCRIPTION: script to restore a database backup overwritting the exising database
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
set -o errexit      # exit immediately if command exits with a non-zero status
#set -x             # essentially debug mode

# assumes that is run after the backup to check.

DATABASE=$1
S3BUCKET=$2
BACKUPDIR=/media/data/postgres/backup

YEAR=`date +%Y`
MONTH=`date +%m`
DAY=`date +%d`

ROLESTODOWNLOAD=$(aws s3 ls s3://$S3BUCKET/$YEAR/$MONTH/ | grep `date +%F` | grep roles | sort -r -k1,2 | head  -1 | awk '{print $4}')
s3cmd --force get $ROLESTODOWNLOAD ${BACKUPDIR}/roles.download
psql -f ${BACKUPDIR}/roles.download  -U postgres

#Latest first
FILETODOWNLOAD=$(aws s3 ls s3://$S3BUCKET/$YEAR/$MONTH/ | grep `date +%F` | grep "$DATABASE".sql.gz | sort -r -k1,2 | head  -1 | awk '{print $4}')

aws s3 cp $FILETODOWNLOAD ${BACKUPDIR}/$DATABASE.download

dropdb ${DATABASE}_backup --if-exists -U postgres
psql -U postgres postgres -c "alter database $DATABASE rename to ${DATABASE}_backup"
psql -U postgres postgres -c "create database $DATABASE"

echo "started load of backup: " && date

pg_restore --exit-on-error -j 3 -e -U postgres -Fc --dbname=$DATABASE ${BACKUPDIR}/$DATABASE.download

echo "completed load of backup: " && date

