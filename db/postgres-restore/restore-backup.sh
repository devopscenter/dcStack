#!/bin/bash

BACKUPFILE=''
BACKUPDIR=/media/data/postgres/backup

function usage
{
  echo "usage: ./restore-backup.sh [--backupfile backup-file] [--list] s3bucket database"
}

if [[ -z $1 ]]; then
  usage
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case $1 in
    --backupfile ) shift
                   BACKUPFILE=$1
                   ;;
    --list )       LIST=1
                   ;;
    [!-]* )        if [[ $# -eq 2 ]]; then
                     S3_BUCKET=$1
                     DBNAME=$2
                     shift;
                   else
                     echo "Too many/few of the 2 required parameters."
                     usage
                     exit 1
                   fi
                   ;;
    * )            usage
                   exit 1
  esac
  shift
done

sudo pip install s3cmd

# list contents of s3 bucket
if ! [[ -z "$LIST" ]]; then
  echo "S3 backups, with most recent listed last"
  s3cmd ls -r s3://"${S3_BUCKET}"/|grep "${DBNAME}".sql.gz|awk -F/ '{print $7}'|sort -V
#  aws s3 ls --recursive s3://"${S3_BUCKET}"/|grep "${DBNAME}".sql.gz|awk -F/ '{print $3}'|sort -V
  exit 1
fi

# if the backup file isn't specified, grab the most recent
if [[ -z "$BACKUPFILE" ]]; then
  S3_FILE=$(s3cmd ls -r s3://"${S3_BUCKET}"/|grep "${DBNAME}.sql.gz"|sort -r -k1,2|head -1|awk '{print $4}')
#  S3_FILE="s3://${S3_BUCKET}/$(aws s3 ls --recursive s3://"${S3_BUCKET}"/|grep "${DBNAME}.sql.gz"|sort -r -k1,2|head -1|awk '{print $4}')"
  BACKUPFILE=$(s3cmd ls -r s3://"${S3_BUCKET}"/|grep "${DBNAME}.sql.gz"|sort -r -k1,2|head -1|awk -F/ '{print $7}')
#  BACKUPFILE=$(aws s3 ls --recursive s3://"${S3_BUCKET}"/|grep "${DBNAME}.sql.gz"|sort -r -k1,2|head -1|awk -F/ '{print $3}')
else
  S3_FILE=$(s3cmd ls -r s3://"${S3_BUCKET}"/|grep "${BACKUPFILE}"|awk '{print $4}')
#  S3_FILE="s3://${S3_BUCKET}/$(aws s3 ls --recursive s3://"${S3_BUCKET}"/|grep "${BACKUPFILE}"|awk '{print $4}')"
fi
S3_YEAR=$(echo "$S3_FILE"|awk -F/ '{print $5}')
S3_MONTH=$(echo "$S3_FILE"|awk -F/ '{print $6}')

sudo s3cmd --force get "s3://${S3_BUCKET}/${S3_YEAR}/${S3_MONTH}/${BACKUPFILE}" "${BACKUPDIR}/${BACKUPFILE}.download"
#sudo aws s3 cp "s3://${S3_BUCKET}/${S3_YEAR}/${S3_MONTH}/${BACKUPFILE}" "${BACKUPDIR}/${BACKUPFILE}.download"

# kill any existing connections, then drop and recreate the db
psql -U postgres -d "$DBNAME" -c "select pg_terminate_backend(pg_stat_activity.pid) from pg_stat_activity where pg_stat_activity.datname = '${DBNAME}' and pid <> pg_backend_pid();"
dropdb "${DBNAME}" --if-exists -U postgres
psql -U postgres postgres -c "create database $DBNAME"

# turn off archive_mode for the restore
sudo sed -i "s/^\barchive_mode\b[[:blank:]]\+=[[:blank:]]\+\bon\b/archive_mode = off/g" /media/data/postgres/db/pgdata/postgresql.conf
sudo supervisorctl restart postgres

echo "Postgresql restore started at " && date
pg_restore --exit-on-error -j 1 -e -U postgres -Fc --dbname="$DBNAME" "${BACKUPDIR}/${BACKUPFILE}.download"

sudo sed -i "s/^\barchive_mode\b[[:blank:]]\+=[[:blank:]]\+\boff\b/archive_mode = on/g" /media/data/postgres/db/pgdata/postgresql.conf
sudo supervisorctl restart postgres
echo "Postgresql restore completed at " && date
