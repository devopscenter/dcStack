#!/bin/bash

BACKUPDIR=/media/data/postgres/backup

function usage
{
  echo "usage: ./restore-wale-backup.sh [--backupfile backup-file] [--recoverytime recovery-time] [--list] s3base s3suffix aws-hostname"
}

if [[ -z $1 ]]; then
  usage
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case $1 in
    --backupfile )   shift
                     BACKUPFILE=$1
                     ;;
    --recoverytime ) shift
                     RECOVERYTIME=$1
                     ;;
    --list )         LIST=1
                     ;;
    [!-]* )          if [[ $# -eq 3 ]]; then
                       S3BASE=$1
                       SUFFIX=$2
		       AWS_HOSTNAME=$3
                       shift; shift;
                     else
                       echo "Too many/few of the 3 required parameters."
                       usage
                       exit 1
                     fi
                     ;;
    * )              usage
                     exit 1
  esac
  shift
done

# list available wal-e backups
if ! [[ -z "$LIST" ]]; then
  sudo su -c "wal-e --aws-instance-profile --s3-prefix s3://${S3BASE}-postgres-wale-${SUFFIX}/${AWS_HOSTNAME} backup-list" -s /bin/sh postgres
  exit 1
fi

sudo supervisorctl stop postgres

# if the backup file isn't specified, use LATEST
if [[ -z "$BACKUPFILE" ]]; then
  sudo su -c "wal-e --aws-instance-profile --s3-prefix s3://${S3BASE}-postgres-wale-${SUFFIX}/${AWS_HOSTNAME} backup-fetch /media/data/postgres/db/pgdata/ LATEST" -s /bin/sh postgres
else
  sudo su -c "wal-e --aws-instance-profile --s3-prefix s3://${S3BASE}-postgres-wale-${SUFFIX}/${AWS_HOSTNAME} backup-fetch /media/data/postgres/db/pgdata/ $BACKUPFILE" -s /bin/sh postgres
fi

# copy backups of postgresql.conf, pg_hba.conf, and pg_ident.conf over to new data dir
sudo cp --preserve /media/data/postgres/backup/postgresql.conf /media/data/postgres/db/pgdata/
sudo cp --preserve /media/data/postgres/backup/pg_hba.conf /media/data/postgres/db/pgdata/
sudo cp --preserve /media/data/postgres/backup/pg_ident.conf /media/data/postgres/db/pgdata/

# create recovery.conf file
echo 'restore_command  = '\''wal-e --aws-instance-profile --s3-prefix s3://${S3BASE}-postgres-wale-${SUFFIX}/${AWS_HOSTNAME} wal-fetch "%f" "%p"'\'|sudo tee -a /media/data/postgres/db/pgdata/recovery.conf > /dev/null
echo 'pause_at_recovery_target = false'|sudo tee -a /media/data/postgres/db/pgdata/recovery.conf > /dev/null
if [[ -n "$RECOVERYTIME" ]]; then
  echo "recovery_target_time = '${RECOVERYTIME}'"|sudo tee -a /media/data/postgres/db/pgdata/recovery.conf > /dev/null
fi

sudo supervisorctl start postgres
