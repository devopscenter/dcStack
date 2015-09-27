#!/bin/bash -e

DATABASE=$1
S3BUCKET=$2

s3cmd ls s3://$S3BUCKET | grep `date +%F` | grep '$DATABASE.sql.gz'

s3cmd get $FILETODOWNLOAD $DATABASE.download

psql -U postgres postgres -c "alter database $DATABASE rename to $DATABASE_backup"
psql -U postgres postgres -c "create database $DATABASE"

pg_restore -e -U postgres -Fc --dbname=$DATABASE $DATABASE.download
