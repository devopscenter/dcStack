#!/bin/bash

DB_USER=$1
DB_PASS=$2

BUCKET_NAME=$3

TIMESTAMP=$(date +%F_%T | tr ':' '-')
TEMP_FILE=$(mktemp tmp.XXXXXXXXXX)
S3_FILE="s3://$BUCKET_NAME/postgres-backup-$TIMESTAMP"

PGPASSWORD=$DB_PASS pg_dumpall -Fc --no-acl -h masterdb_1 -U $DB_USER > $TEMP_FILE
s3cmd put $TEMP_FILE $S3_FILE
rm "$TEMP_FILE"
