#!/usr/bin/env bash
#===============================================================================
#
#          FILE: mongo_daily_backup.sh
#
#         USAGE: mongo_daily_backup.sh
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
#       CREATED: 03/11/19
#      REVISION:  ---
#
# Copyright 2014-2019 devops.center llc
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

AWS_HOSTNAME="$HOSTNAME"
BUCKET_NAME=$dc_TAG_App-$dcEnv-backups


echo -e "\n\nPerforming full mongo backups"
echo -e "--------------------------------------------\n"


TIMESTAMP=$(date +%F_%T | tr ':' '-')
YEAR=$(date +%Y)
MONTH=$(date +%m)
#                                S3_FILE="s3://$BUCKET_NAME/${YEAR}/${MONTH}/"$DATABASE".sql.gz-$TIMESTAMP"

mongo_dir="mongo-tmp"
tar_file="mongo.tar.gz-$TIMESTAMP"
s3_file="s3://$BUCKET_NAME/mongo/${AWS_HOSTNAME}/${YEAR}/${MONTH}/$tar_file"

cd /media/data/tmp 

mongodump -o $mongo_dir
tar -czf $tar_file $mongo_dir

aws s3 cp $tar_file $s3_file

rm -rf $mongo_dir
rm $tar_file

echo -e "\nAll mongo database backups complete!"
