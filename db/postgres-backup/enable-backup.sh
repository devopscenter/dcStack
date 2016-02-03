#!/bin/bash

S3_BUCKET=$1
#CRON_MINUTE=$2
#CRON_HOUR=$3
#CRON_MONTHDAY=$4
#CRON_MONTH=$5
#CRON_WEEKDAY=$6

sudo pip install s3cmd

# copy over backup script and config, update s3 bucket in config.
cd ~/docker-stack/db/postgres-backup/
sudo cp pg_backup.config /media/data/postgres/backup/pg_backup.config
sudo cp pg_backup_rotated_new.sh /media/data/postgres/backup/pg_backup_rotated_new.sh
sudo chmod 0755 /media/data/postgres/backup/pg_backup_rotated_new.sh
sudo sed "s/^BUCKET_NAME=.*/BUCKET_NAME=${S3_BUCKET}/" pg_backup.config

# add cron job to run the backup daily
#sudo (crontab -u postgres -l 2>/dev/null; echo "$1 $2 $3 $4 $5 /path/to/job -with args") | crontab -u postgres -
(sudo crontab -u postgres -l 2>/dev/null; echo "01 04  *   *   *     /media/data/postgres/backup/pg_backup_rotated_new.sh -c /media/data/postgres/backup/pg_backup.config") | sudo crontab -u postgres -

# jenkins setup
