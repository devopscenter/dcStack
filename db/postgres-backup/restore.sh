#!/bin/bash -e

DATABASE=$1
S3BUCKET=$2

YEAR=`date +%Y`
MONTH=`date +%m`
DAY=`date +%d`


ROLESTODOWNLOAD=$(s3cmd ls s3://$S3BUCKET/$YEAR/$MONTH/ | grep `date +%F -d "yesterday"` | grep roles | sort -r -k1,2 | head  -1 | awk '{print $4}')
s3cmd --force get $ROLESTODOWNLOAD roles.download
psql -f roles.download  -U postgres

#Latest first
FILETODOWNLOAD=$(s3cmd ls s3://$S3BUCKET/$YEAR/$MONTH/ | grep `date +%F -d "yesterday"` | grep "$DATABASE".sql.gz | sort -r -k1,2 | head  -1 | awk '{print $4}')

s3cmd --force get $FILETODOWNLOAD $DATABASE.download

psql -U postgres postgres -c "alter database $DATABASE rename to ${DATABASE}_backup"
psql -U postgres postgres -c "create database $DATABASE"

pg_restore -e -U postgres -Fc --dbname=$DATABASE $DATABASE.download
