#!/bin/bash

function usage
{
  echo "usage: ./restore-pgdump-backup.sh [--schema-only] [--backup local-backup-filename] database-name"
}

if [[ -z $1 ]]; then
  usage
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case $1 in
    --schema-only ) SCHEMA_ONLY=1
                    ;;
    --backup )      shift
                    LOCAL_BACKUP_FILE=$1
                    ;;
    [!-]* )         if [[ $# -eq 1 ]]; then
                      DB_NAME=$1
                      shift;
                    else
                      echo "Too many/few of the 1 required parameters."
                      usage
                      exit 1
                    fi
                    ;;
    * )             usage
                    exit 1
  esac
  shift
done

# kill any existing connections, then drop and recreate the db
sudo -u postgres psql -U postgres -d "$DB_NAME" -c "select pg_terminate_backend(pg_stat_activity.pid) from pg_stat_activity where pg_stat_activity.datname = '${DB_NAME}' and pid <> pg_backend_pid();"
sudo -u postgres dropdb -U postgres "${DB_NAME}" --if-exists
sudo -u postgres psql -U postgres postgres -c "create database $DB_NAME"

# turn off archive_mode for the restore and restart postgres
sudo sed -i "s/^\barchive_mode\b[[:blank:]]\+=[[:blank:]]\+\bon\b/archive_mode = off/g" /media/data/postgres/db/pgdata/postgresql.conf
sudo supervisorctl restart postgres

# if no backup file is provided, look for the most recent pgdump file in the backup dir
if [[ -z "$LOCAL_BACKUP_FILE" ]]; then
  LOCAL_BACKUP_FILE="$(find /home/ubuntu -maxdepth 1 -iname "*.download"|tail -1)"
  if [[ -z "$LOCAL_BACKUP_FILE" ]]; then
    echo "No local backup found, exiting."
    exit 1
  fi
fi

# schema-only restore if --schema-only is passed, otherwise do full restore
echo "Postgresql restore started at " && date
if ! [[ -z "$SCHEMA_ONLY" ]]; then
  sudo -u postgres pg_restore -U postgres -s --exit-on-error -j 1 -e -Fc --dbname="$DB_NAME" "$LOCAL_BACKUP_FILE"
else
  sudo -u postgres pg_restore -U postgres --exit-on-error -j 1 -e -Fc --dbname="$DB_NAME" "$LOCAL_BACKUP_FILE"
fi

# turn on archive_mode after restore is complete and restart postgres
sudo sed -i "s/^\barchive_mode\b[[:blank:]]\+=[[:blank:]]\+\boff\b/archive_mode = on/g" /media/data/postgres/db/pgdata/postgresql.conf
sudo supervisorctl restart postgres
echo "Postgresql restore completed at " && date
