#!/bin/bash

function usage
{
  echo "usage: ./download-and-restore.sh [--schema-only] [--s3backupfile s3-backup-filename] s3bucket database"
}


if [[ -z $1 ]]; then
  usage
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case $1 in
    --schema-only )  SCHEMA_ONLY=1
                     ;;
    --s3backupfile ) shift
                     S3_BACKUP_FILE=$1
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

# download the backup
if [[ -z "$S3_BACKUP_FILE" ]]; then
  source ./download-pgdump-backup.sh "$S3_BUCKET" "$DB_NAME"
else
  source ./download-pgdump-backup.sh --s3backupfile "$S3_BACKUP_FILE" "$S3_BUCKET" "$DB_NAME"
fi

# restore the backup or schema
if [[ -z "$SCHEMA_ONLY" ]]; then
  ./restore-pgdump-backup.sh "$LOCAL_BACKUP_FILE" "$DB_NAME"
else
  ./restore-pgdump-backup.sh --schema-only "$LOCAL_BACKUP_FILE" "$DB_NAME"
fi
