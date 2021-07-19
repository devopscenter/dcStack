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

logger "jenkins backup started"

# Define cleanup as an exit trap, so happens no matter what
function finish {
    pushd /media/data/tmp
	sudo rm "$JENKINS_BACKUP_FILE"
	sudo rm excludefiles
    sudo supervisorctl start jenkins            # just incase the tar had failed, triggering the exit before the ordinary start
	popd
}
trap finish EXIT



# create the temporary directory if it doesn't exist
if [[ ! -d /media/data/tmp ]]; then
    sudo mkdir /media/data/tmp
    sudo chmod 777 /media/data/tmp
fi

# create temporary tar file
JENKINS_BACKUP_FILE=$(mktemp /media/data/tmp/jenkins.tar.gz.XXXXX)

# create s3 bucket if it doesn't already exist
#/usr/local/bin/s3cmd mb "s3://${BUCKET_NAME}"
#s3cmd mb "s3://${BUCKET_NAME}"

# tar just the backup data needed to load onto a new instance.
# Tip on using a find to exclude from tar courtesy of https://stackoverflow.com/a/30037079/8417759
pushd /media/data/tmp
sudo find ~ -type d -name *workspace* > excludefiles

logger "stopping jenkins"
sudo supervisorctl stop jenkins
sudo tar czf "$JENKINS_BACKUP_FILE" /media/data/jenkins -X excludefiles
sudo supervisorctl start jenkins
logger "started jenkins"

# upload to s3
aws s3 cp "$JENKINS_BACKUP_FILE" "s3://${S3_FILE}"

popd

logger "jenkins backup finished"
