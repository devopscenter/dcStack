#!/bin/bash -e

BACKUP_DIR='/media/data/postgres/backup'

function usage
{
  echo "usage: ./download-pgdump-backup.sh [--s3backupfile s3-backup-file] [--list] s3bucket database"
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

sudo pip install s3cmd

# store list of backups from s3 bucket
  S3_LIST=$(s3cmd ls -r s3://"${S3_BUCKET}"/|grep "${DB_NAME}".sql.gz)

# if --list is specified, print list and exit
if ! [[ -z "$LIST" ]]; then
  echo "S3 backups, with most recent listed last"
  echo "$S3_LIST"|awk -F/ '{print $7}'|sort -V
  exit
fi

# if the backup file name is given, download the specified file
if [[ "$S3_BACKUP_FILE" ]]; then
  S3_FILE=$(echo "$S3_LIST"|grep "${S3_BACKUP_FILE}"|awk '{print $4}')
# if backup file name isn't given, download the most recent
else
  S3_FILE=$(echo "$S3_LIST"|sort -r -k1,2|head -1|awk '{print $4}')
  S3_BACKUP_FILE=$(echo "$S3_LIST"|sort -r -k1,2|head -1|awk -F/ '{print $7}')
fi
S3_YEAR=$(echo "$S3_FILE"|awk -F/ '{print $5}')
S3_MONTH=$(echo "$S3_FILE"|awk -F/ '{print $6}')

LOCAL_BACKUP_FILE="${BACKUP_DIR}/${S3_BACKUP_FILE}.download"
sudo s3cmd --force get "s3://${S3_BUCKET}/${S3_YEAR}/${S3_MONTH}/${S3_BACKUP_FILE}" "$LOCAL_BACKUP_FILE"
export LOCAL_BACKUP_FILE
