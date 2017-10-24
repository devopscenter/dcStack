#!/usr/bin/env bash
#===============================================================================
#
#          FILE: download-pgdump-backup.sh
# 
#         USAGE: ./download-pgdump-backup.sh 
# 
#   DESCRIPTION: This script will allow the user to download a database backup
#                from AWS S3 storage.  You can get a list of the backups by
#                providing the --list option and it will display a list of the
#                backups with the most recent one last. There are four columes
#                to the list output, date, time, size of backup, and the name.
#                you can copy the name and add it as the --s3backupfile option
#                or you can leave off that option and just provide the s3bucket
#                and database name.  This will go through that list and automatically
#                get the lastest one and down load it.
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#                Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 04/20/2017 11:33:18
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

BACKUP_DIR='/media/data/db_restore'

function usage
{
  echo "usage: ./download-pgdump-backup.sh [--s3backupfile s3-backup-file] [--list] [-n] s3bucket database"
}

if [[ -z $1 ]]; then
  usage
  exit 1
fi


while [[ $# -gt 0 ]]; do
  case $1 in
    --s3backupfile ) shift
                     S3_BACKUP_FILE=$1
                     ;;
    --list )         LIST=1
                     ;;
    -n )             NO_OVERWRITE=1
                     ;;
    [!-]* )          if [[ $# -eq 2 ]]; then
                       S3_BUCKET=$1
                       DB_NAME=$2
                       shift;
                     else
                       echo "Too many/few of the 2 required parameters."
                       usage
                       exit 1
                     fi
                     ;;
    * )              usage
                     exit 1
  esac
  shift
done

#-------------------------------------------------------------------------------
# store list of backups from s3 bucket
#-------------------------------------------------------------------------------
S3_AS_STRING=$(aws s3 ls --recursive s3://"${S3_BUCKET}"/|grep "${DB_NAME}".sql.gz)
S3_SORTED_AS_STRING=$(echo "${S3_AS_STRING}" | sort -V)
# turn the string into an array
IFS=$'\n'; S3_LIST=($S3_SORTED_AS_STRING); unset IFS;


#-------------------------------------------------------------------------------
# if --list is specified, print list and exit
#-------------------------------------------------------------------------------
if ! [[ -z "$LIST" ]]; then
    echo "S3 backups, with most recent listed last"
    for item in "${S3_LIST[@]}"; do
        echo "${item}"
    done
    exit
fi

#-------------------------------------------------------------------------------
# if the backup file name is given, download the specified file
#-------------------------------------------------------------------------------
if [[ -z "$S3_BACKUP_FILE" ]]; then
    # download the most recent
    numItems=$((${#S3_LIST[@]}-1))
    S3_BACKUP_FILE=$(echo ${S3_LIST[${numItems}]} | cut -d ' ' -f 4)
fi

#-------------------------------------------------------------------------------
# save off, from the end, everything up the last slash to get just the database backup name
#-------------------------------------------------------------------------------
JUST_THE_BACKUP_NAME=${S3_BACKUP_FILE##*/}
LOCAL_BACKUP_FILE="${BACKUP_DIR}/${JUST_THE_BACKUP_NAME}.download"

if [[ -f "$LOCAL_BACKUP_FILE" ]] && ! [[ -z "$NO_OVERWRITE" ]]; then
    echo -e "\nFile $LOCAL_BACKUP_FILE already exists and -n option was given. Skipping."
else
    #-------------------------------------------------------------------------------
    # A little housecleaning- deleting any previous downloaded backups before getting the new one.
    # At some point this could be made optional (e.g. a -noclean option)
    #-------------------------------------------------------------------------------
    sudo -u postgres rm -f ${BACKUP_DIR}/*.download
    echo "Getting the backup file: ${S3_BACKUP_FILE} from the s3bucket: ${S3_BUCKET}"
    sudo -u postgres s3cmd --force get "s3://${S3_BUCKET}/${S3_BACKUP_FILE}" "$LOCAL_BACKUP_FILE"
fi
export LOCAL_BACKUP_FILE

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
