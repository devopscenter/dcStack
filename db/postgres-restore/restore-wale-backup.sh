#!/usr/bin/env bash
#===============================================================================
#
#          FILE: restore-wale-backup.sh
#
#         USAGE: ./restore-wale-backup.sh
#
#   DESCRIPTION: This script will restore a database from a wal-e backup with the
#                capability of restoring from a specific time as well.
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#                Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 06/30/2017 08:10:07
#      REVISION:  ---
#
# Copyright 2014-2017 devops.center llc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#===============================================================================

#set -o nounset     # Treat unset variables as an error
#set -o errexit      # exit immediately if command exits with a non-zero status
#set -x             # essentially debug mode

#-------------------------------------------------------------------------------
# bring in the devops.center dcLog functions 
#-------------------------------------------------------------------------------
#source /usr/local/bin/dcEnv.sh

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  usage
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
function usage
{
    echo "usage: ./restore-wale-backup.sh [--backupfile backup-file] [--recoverytime recovery-time] [--list] s3base aws-hostname"
    echo 
    echo "This script will restore a database from a wal-e backup with the capability of restoring from a specific time as well."
    echo
    echo "s3base - This is a term that is made up of the application name and the environment separated by a dash (ie dcDemoBlog-dev)"
    echo "aws-hostname - This is the database instance hostname (ie dcDemoBlog-dev-db7) "
    echo
    echo "Recover from a specific point in time.  You can recover the database from a specific point in time by specifying the"
    echo "--recoverytime option.  The value of the recovery time needs to follow this format: 2017-02-01 19:58:55"
    echo "You will need to put double quotes around it to ensure that the option sees it as one argument."
    echo
    echo "If you already know the name of the backup file you want wal-e to pull down you can specify that name with the"
    echo " --backupfile option and it will"
}


#-------------------------------------------------------------------------------
# option checking
#-------------------------------------------------------------------------------
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
        [!-]* )     if [[ $# -eq 2 ]]; then
                        S3BASE=$1
                        AWS_HOSTNAME=$2
                        shift;
                    else
                       echo "Too many/few of the 2 required parameters."
                       usage
                       exit 1
                    fi
                 ;;
        * )      usage
                 exit 1
    esac
    shift
done

#dcStartLog "Restoring database backup with wal-e backup"
echo "Restoring database backup with wal-e backup"

#-------------------------------------------------------------------------------
# check to make sure they have AWS_REGION set in the environment to the appropriate
# S3 region that has there backup in it.  The region was determined when the instances
# were created.
#-------------------------------------------------------------------------------
if [[ -z ${AWS_REGION} ]]; then
    echo "NOTE: The AWS S3 REGION needs to be set."
    echo "      (ie, export AWS_REGION=\"us-west-2\")"
    exit
fi

#-------------------------------------------------------------------------------
# list available wal-e backups and exit
#-------------------------------------------------------------------------------
set -x
if ! [[ -z "$LIST" ]]; then
    #dcLog "Giving a list of wal-e backups only and exiting"
    echo "Giving a list of wal-e backups only and exiting"
    sudo su -s /bin/sh postgres -c "export AWS_REGION=$AWS_REGION; wal-e --aws-instance-profile --s3-prefix s3://${S3BASE}-postgres-wale/${AWS_HOSTNAME} backup-list"
    exit 1
fi

#-------------------------------------------------------------------------------
# Need to stop postgres first
#-------------------------------------------------------------------------------
#dcLog "stopping postgres"
echo "stopping postgres"
sudo supervisorctl stop postgres

#-------------------------------------------------------------------------------
#  Not sure what goes into this directory but maybe it is something that wal-e uses
#-------------------------------------------------------------------------------
if [[ ! -d /media/data/postgres/xlog/transactions ]]; then
    sudo mkdir /media/data/postgres/xlog/transactions
    sudo chown postgres:postgres /media/data/postgres/xlog/transactions
fi

#-------------------------------------------------------------------------------
# make copies of files needed for wal-e restore
#-------------------------------------------------------------------------------
sudo cp --preserve /media/data/postgres/db/pgdata/postgresql.conf /media/data/postgres/backup/
sudo cp --preserve /media/data/postgres/db/pgdata/pg_ident.conf /media/data/postgres/backup/
sudo cp --preserve /media/data/postgres/db/pgdata/pg_hba.conf /media/data/postgres/backup/

#-------------------------------------------------------------------------------
# in order to get ready for the backup-fetch the database directory needs to be
# cleared.  Note, the good postgres conf files are already in the backup directory
# so afterwards they will be copied in.
#-------------------------------------------------------------------------------
sudo -u postgres rm -rf /media/data/postgres/db/pgdata
sudo -u postgres mkdir /media/data/postgres/db/pgdata
sudo -u postgres chmod 700 /media/data/postgres/db/pgdata

#-------------------------------------------------------------------------------
# if the backup file isn't specified, use LATEST...but we do need to transfer a 
# backup over so that we can recover from it.
#-------------------------------------------------------------------------------
#dcLog "doing a wal-e backup-fetch to get the backup file"
echo "doing a wal-e backup-fetch to get the backup file"
if [[ -z "$BACKUPFILE" ]]; then
    sudo su -s /bin/sh postgres -c "export AWS_REGION=$AWS_REGION; wal-e --aws-instance-profile --s3-prefix s3://${S3BASE}-postgres-wale/${AWS_HOSTNAME} backup-fetch /media/data/postgres/db/pgdata/ LATEST"
else
    sudo su -s /bin/sh postgres -c "export AWS_REGION=$AWS_REGION; wal-e --aws-instance-profile --s3-prefix s3://${S3BASE}-postgres-wale/${AWS_HOSTNAME} backup-fetch /media/data/postgres/db/pgdata/ $BACKUPFILE"
fi
if [[ $? -gt 0 ]]; then
    echo "The backup-fetch did not complete, exiting..."
    sudo supervisorctl start postgres
    exit 1
fi

#-------------------------------------------------------------------------------
# make backups of postgresql.conf, pg_hba.conf, and pg_ident.conf by copying over to new data dir
#-------------------------------------------------------------------------------
#dcLog "making backups of the necessary postgres conf files"
echo "making backups of the necessary postgres conf files"
#sudo cp --preserve /media/data/postgres/backup/postgresql.conf.wale /media/data/postgres/db/pgdata/postgresql.conf
sudo cp --preserve /media/data/postgres/backup/postgresql.conf /media/data/postgres/db/pgdata/
sudo cp --preserve /media/data/postgres/backup/pg_hba.conf /media/data/postgres/db/pgdata/
sudo cp --preserve /media/data/postgres/backup/pg_ident.conf /media/data/postgres/db/pgdata/

# create recovery.conf file

#-------------------------------------------------------------------------------
# Need to create the recovery.conf file that postgres will see when it starts up.  It will then
# execute what it finds in the recover.conf file into a database.  
# NOTE: the database that it recovers to is not the main database and will need to be promoted
#       once it has been checked for accuracy
#-------------------------------------------------------------------------------
#dcLog "creating the recover.conf file"
echo "creating the recover.conf file"
if [[ -z "${RECOVERYTIME}" ]]; then
    cat <<- EOF1 | sudo tee /media/data/postgres/db/pgdata/recovery.conf > /dev/null
restore_command = 'export AWS_REGION=${AWS_REGION}; wal-e --aws-instance-profile --s3-prefix s3://${S3BASE}-postgres-wale/${AWS_HOSTNAME} wal-fetch %f %p'
pause_at_recovery_target = false
EOF1
else
    cat <<- EOF2 | sudo tee /media/data/postgres/db/pgdata/recovery.conf > /dev/null
restore_command = 'export AWS_REGION=${AWS_REGION}; wal-e --aws-instance-profile --s3-prefix s3://${S3BASE}-postgres-wale/${AWS_HOSTNAME} wal-fetch %f %p'
pause_at_recovery_target = false
recovery_target_time = '${RECOVERYTIME}'
EOF2
fi

#-------------------------------------------------------------------------------
# chown owner of the recovery.conf file so that postgres will see and use it correctly
#-------------------------------------------------------------------------------
sudo chown postgres:postgres /media/data/postgres/db/pgdata/recovery.conf

#dcLog "starting the database"
echo "starting the database"
sudo supervisorctl start postgres

# ensure postgres has started
sleep 5

# create a basebackup to allow for wal-e restores on this host
sudo su -s /bin/sh postgres -c  "export AWS_REGION=${AWS_REGION}; wal-e --aws-instance-profile --s3-prefix s3://${S3BASE}-postgres-wale/${AWS_HOSTNAME} backup-push /media/data/postgres/db/pgdata"
if [[ $? -gt 0 ]]; then
    echo "It doesn't appear that the database is active yet, you will need to wait and try creating the wal-e baseline backup later."
fi

#dcEndLog "Finished..."
echo "Finished..."

