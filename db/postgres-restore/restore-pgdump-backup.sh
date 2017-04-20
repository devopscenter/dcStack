#!/bin/bash - 
#===============================================================================
#
#          FILE: restore-pgdump-backup.sh
# 
#         USAGE: ./restore-pgdump-backup.sh 
# 
#   DESCRIPTION: This script will put the postgresql database in a state that will
#                allow it to receive the restore of data from a backup of the prod
#                database.
#
#                NOTE: the shebang bash at the top of the file does not have 
#                a -e that would make the script exit on a failed command within 
#                this script.  As there may be a command that will fail and we 
#                need to do something more intelligent with that knowledge that 
#                exit (like try the command again or pause...).
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Original author unknown
#       AUTHOR2: Gregg Jensen (), gjensen@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 09/20/2016 12:48:37
#      REVISION:  ---
#===============================================================================

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


set -x
#-------------------------------------------------------------------------------
# First check to see if the database exists
#-------------------------------------------------------------------------------
DB_EXISTS=$(sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -c ${DB_NAME} )

if [[ ${DB_EXISTS} ]]; then
    #-------------------------------------------------------------------------------
    # kill any existing connections, then drop and recreate the db
    # note for the following sections, due to an issue with the database not being ready
    # at various times after the dropdb, there is a loop around each of the commands. 
    # This loop will ensure the action takes place at least one and if the return value
    # is an error than try again after a brief pause.
    #-------------------------------------------------------------------------------
    for value in {1..3}
    do
        sudo -u postgres psql -U postgres -d "$DB_NAME" -c "select pg_terminate_backend(pg_stat_activity.pid) from pg_stat_activity where pg_stat_activity.datname = '${DB_NAME}' and pid <> pg_backend_pid();"
        if [ $? -gt 0 ]
        then 
            if [ $value -eq 3 ] 
            then
                echo "Terminating because pg_terminate_backend failed to execute properly"
                exit 1
            else 
                sleep 1
            fi
        else
            break
        fi
    done

    for value in {1..3}
    do
        echo "Dropping database ${DB_NAME}"
        #sudo -u postgres dropdb -U postgres "${DB_NAME}" --if-exists
        sudo -u postgres dropdb -U postgres "${DB_NAME}"
        if [ $? -gt 0 ]
        then 
            if [ $value -eq 3 ] 
            then
                echo "Terminating because dropdb failed to execute properly"
                exit 1
            else 
                sleep 1
            fi
        else
            break
        fi
    done
fi # end if database exists check

for value in {1..3}
do
    sudo -u postgres psql -U postgres postgres -c "create database $DB_NAME"
    if [ $? -gt 0 ]
    then 
        if [ $value -eq 3 ] 
        then
            echo "Terminating because the create database failed to execute properly"
            exit 1
        else 
            sleep 1
        fi
    else
        break
    fi
done

# turn off archive_mode for the restore and restart postgres
sudo sed -i "s/^\barchive_mode\b[[:blank:]]\+=[[:blank:]]\+\bon\b/archive_mode = off/g" /media/data/postgres/db/pgdata/postgresql.conf
sudo supervisorctl restart postgres
set +x

# if no backup file is provided, look for the most recent pgdump file in the backup dir
if [[ -z "$LOCAL_BACKUP_FILE" ]]; then

    echo "Looking for backupfile: /media/data/postgres/backup/${DB_NAME}*.download"
    LOCAL_BACKUP_FILE="$(find /media/data/postgres/backup -maxdepth 1 -iname "${DB_NAME}*.download"| sort |tail -1)"
    if [[ -z "$LOCAL_BACKUP_FILE" ]]; then
        echo "No local backup found, exiting."
        exit 1
    fi
fi

# schema-only restore if --schema-only is passed, otherwise do full restore
echo "Postgresql restore of backup: ${LOCAL_BACKUP_FILE} started at " && date
if ! [[ -z "$SCHEMA_ONLY" ]]; then
  sudo -u postgres pg_restore -U postgres -s --exit-on-error -j 1 -e -Fc --dbname="$DB_NAME" "$LOCAL_BACKUP_FILE" || exit 1
  sudo -u postgres pg_restore -U postgres --data-only -t django_migrations -j 1 -e -Fc --dbname="$DB_NAME" "$LOCAL_BACKUP_FILE"
  sudo psql -U postgres -d "$DB_NAME" -c "SELECT setval('django_migrations_id_seq', COALESCE((SELECT MAX(id)+1 FROM django_migrations), 1), false);"
else
  sudo -u postgres pg_restore -U postgres --exit-on-error -j 1 -e -Fc --dbname="$DB_NAME" "$LOCAL_BACKUP_FILE" || exit 1
fi

# turn on archive_mode after restore is complete and restart postgres
sudo sed -i "s/^\barchive_mode\b[[:blank:]]\+=[[:blank:]]\+\boff\b/archive_mode = on/g" /media/data/postgres/db/pgdata/postgresql.conf
sudo supervisorctl restart postgres
echo "Postgresql restore completed at " && date
