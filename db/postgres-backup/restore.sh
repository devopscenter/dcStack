#!/bin/bash -e

# assumes that is run after the backup to check.

DATABASE=$1
S3BUCKET=$2
BACKUPDIR=/media/data/postgres/backup

YEAR=`date +%Y`
MONTH=`date +%m`
DAY=`date +%d`

ROLESTODOWNLOAD=$(s3cmd ls s3://$S3BUCKET/$YEAR/$MONTH/ | grep `date +%F` | grep roles | sort -r -k1,2 | head  -1 | awk '{print $4}')
s3cmd --force get $ROLESTODOWNLOAD ${BACKUPDIR}/roles.download
psql -f ${BACKUPDIR}/roles.download  -U postgres

#Latest first
FILETODOWNLOAD=$(s3cmd ls s3://$S3BUCKET/$YEAR/$MONTH/ | grep `date +%F` | grep "$DATABASE".sql.gz | sort -r -k1,2 | head  -1 | awk '{print $4}')

s3cmd --force get $FILETODOWNLOAD ${BACKUPDIR}/$DATABASE.download

dropdb ${DATABASE}_backup --if-exists -U postgres
psql -U postgres postgres -c "alter database $DATABASE rename to ${DATABASE}_backup"
psql -U postgres postgres -c "create database $DATABASE"

pg_restore --exit-on-error -j 3 -e -U postgres -Fc --dbname=$DATABASE ${BACKUPDIR}/$DATABASE.download
