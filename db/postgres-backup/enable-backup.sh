#!/usr/bin/env bash
#===============================================================================
#
#          FILE: enable-backup.sh
#
#         USAGE: enable-backup.sh
#
#   DESCRIPTION: script to turn on bakups within cron
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

S3_BUCKET=$1
BACKUP_S3_REGION=$2
ENCRYPT_FS=$3
#CRON_MINUTE=$2
#CRON_HOUR=$3
#CRON_MONTHDAY=$4
#CRON_MONTH=$5
#CRON_WEEKDAY=$6

sudo pip install s3cmd

# copy over backup script and config, update s3 bucket in config.
cd ~/dcStack/db/postgres-backup/
sudo cp pg_backup.config /media/data/postgres/backup/pg_backup.config
sudo cp pg_backup_rotated.sh /media/data/postgres/backup/pg_backup_rotated.sh
sudo chmod 0755 /media/data/postgres/backup/pg_backup_rotated.sh
sudo sed -i "s/^BUCKET_NAME=.*/BUCKET_NAME=${S3_BUCKET}/" /media/data/postgres/backup/pg_backup.config

# create bucket if it doesn't exist
if ! s3cmd ls s3://"$S3_BUCKET" > /dev/null 2>&1; then
    s3cmd --bucket-location=${BACKUP_S3_REGION} mb s3://"${S3_BUCKET}"
    if [[ ${ENCRYPT_FS} == "true" ]]; then
        # create a json string that represents the structure needed to define the
        # default encryption for the S3 bucket
        ENCRYPT_JSON='{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
        aws --region ${BACKUP_S3_REGION} s3api put-bucket-encryption --bucket "${S3_BUCKET}" --server-side-encryption-configuration ${ENCRYPT_JSON}
    fi
fi

# add cron job to run the backup daily
#sudo (crontab -u postgres -l 2>/dev/null; echo "$1 $2 $3 $4 $5 /path/to/job -with args") | crontab -u postgres -
(sudo crontab -u postgres -l 2>/dev/null; echo "01 04  *   *   *     /media/data/postgres/backup/pg_backup_rotated.sh -c /media/data/postgres/backup/pg_backup.config") | sudo crontab -u postgres -

# jenkins setup
