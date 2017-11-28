#!/usr/bin/env bash
#===============================================================================
#
#          FILE: jenkins-backup.sh
#
#         USAGE: jenkins-backup.sh
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
set -o errexit      # exit immediately if command exits with a non-zero status
#set -x             # essentially debug mode

BUCKET_NAME=$1

TIMESTAMP=$(date +%F_%T | tr ':' '-')
YEAR=$(date +%Y)
MONTH=$(date +%m)
S3_FILE="${BUCKET_NAME}/${HOSTNAME}/${YEAR}/${MONTH}/jenkins-${TIMESTAMP}.tar.gz"

# create the temporary directory if it doesn't exist
if [[ ! -d /media/data/tmp ]]; then
    sudo mkdir /media/data/tmp
    sudo chmod 777 /media/data/tmp
fi

# create temporary tar file
JENKINS_BACKUP_FILE=$(mktemp /media/data/tmp/jenkins.tar.gz.XXXXX)

# create s3 bucket if it doesn't already exist
#/usr/local/bin/s3cmd mb "s3://${BUCKET_NAME}"
s3cmd mb "s3://${BUCKET_NAME}"

# tar both jenkins directories
sudo tar czvf "$JENKINS_BACKUP_FILE" /media/data/jenkins /var/lib/jenkins

# upload to s3
#/usr/local/bin/s3cmd put "$JENKINS_BACKUP_FILE" "s3://${S3_FILE}"
s3cmd put "$JENKINS_BACKUP_FILE" "s3://${S3_FILE}"

# remove temporary file
if [[ -f "$JENKINS_BACKUP_FILE" ]]; then
  rm "$JENKINS_BACKUP_FILE"
fi
