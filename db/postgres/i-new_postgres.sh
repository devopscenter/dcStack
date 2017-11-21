#!/usr/bin/env bash
#===============================================================================
#
#          FILE: i-new_postgres.sh
# 
#         USAGE: ./i-new_postgres.sh 
# 
#   DESCRIPTION:  Set up the postgres instance 
# 
#       OPTIONS: ---
#  REQUIREMENTS: 
#                PRIVATE_IP=$1
#                VPC_CIDR=$3
#                DATABASE=$4
#                S3_BACKUP_BUCKET=$5
#                S3_WALE_BUCKET=$6
#                PGVERSION=$7
#                DNS_METHOD=$8
#                ENV=$9
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#                Bob Lozano (), bob@devops.center
#        AUTHOR2: Josh, Trey
#  ORGANIZATION: devops.center
#       CREATED: 09/29/2016 09:11:12
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
set -x             # essentially debug mode
set -o verbose

CUST_APP_NAME=$1
PRIVATE_IP=$2
VPC_CIDR=$3
DATABASE=$4
S3_BACKUP_BUCKET=$5
S3_WALE_BUCKET=$6
PGVERSION=$7
DNS_METHOD=$8
ENV=$9
DCTYPE=${10}
BACKUP_S3_REGION=${11}
PUBLIC_IP=${12}
ROLE=${13}
ENCRYPT_FS=${14}
PROFILE=${15}

if  [[ -z "$PRIVATE_IP" ]] ||
    [[ -z "$VPC_CIDR" ]] ||
    [[ -z "$DATABASE" ]] ||
    [[ -z "$S3_BACKUP_BUCKET" ]] ||
    [[ -z "$S3_WALE_BUCKET" ]] ||
    [[ -z "$PGVERSION" ]] ||
    [[ -z "$DCTYPE}" ]] ||
    [[ -z "$BACKUP_S3_REGION}" ]] ||
    [[ -z "$ENV" ]]; then

    echo "14 Arguments are required: "
    echo "    PRIVATE_IP: ${PRIVATE_IP}"
    echo "    VPC_CIDR: ${VPC_CIDR}"
    echo "    DATABASE: ${DATABASE}"
    echo "    S3_BACKUP_BUCKET: ${S3_BACKUP_BUCKET}"
    echo "    S3_WALE_BUCKET: ${S3_WALE_BUCKET}"
    echo "    PGVERSION: ${PGVERSION}"
    echo "    DNS_METHOD: ${DNS_METHOD}"
    echo "    ENV: ${ENV}"
    echo "    DCTYPE: ${DCTYPE}"
    echo "    BACKUP_S3_REGION: ${BACKUP_S3_REGION}"
    echo "    PUBLIC_IP: ${PUBLIC_IP}"
    echo "    ROLE: ${ROLE}"
    echo "    ENCRYPT_FS: ${ENCRYPT_FS}"
    echo
    echo -e "Examples:"
    echo -e "Postgresql 9.4 using /etc/hosts for DNS:   ./i-new_postgres.sh 10.0.0.15 logs.papertrailapp.com:12345 10.0.0.0/16 test-postgres-backup-dev 9.4 etchosts"
    echo -e "Postgresql 9.5 using Route53 for DNS:      ./i-new_postgres.sh 10.0.0.15 logs.papertrailapp.com:12345 10.0.0.0/16 test-postgres-backup-dev 9.5\n"
    echo -e "Note: to use Route53 for DNS, you can omit the last argument.  To use the /etc/hosts file, add etchosts as the 8th and final argument."
    exit 1
fi

#-------------------------------------------------------------------------------
# if not using route53, add private IP to /etc/hosts
#-------------------------------------------------------------------------------
if [[ "$DNS_METHOD" = 'etchosts' ]]; then
    if ! (grep -q "^${PRIVATE_IP}\b.*\bpgmaster-1\b" /etc/hosts); then
        echo "${PRIVATE_IP} pgmaster-1" | sudo tee -a /etc/hosts > /dev/null
    fi
fi

#-------------------------------------------------------------------------------
# install standard packages/utilities
#-------------------------------------------------------------------------------
cd ~/dcStack/buildtools/utils/ || exit
sudo ./base-utils.sh

#-------------------------------------------------------------------------------
# install python and pip directly rather than via python/python.sh
#-------------------------------------------------------------------------------
sudo apt-fast -qq -y install python-dev python-pip

cd ~/dcStack/buildtools/utils || exit
sudo ./install-supervisor.sh normal

#-------------------------------------------------------------------------------
# create env variables so supervisor can start
#-------------------------------------------------------------------------------
if [[ (-n "${ENV}") && (-e "${HOME}/${CUST_APP_NAME}/${CUST_APP_NAME}-utils/environments/${ENV}.env") ]]; then
    pushd ~/dcUtils/
    ./deployenv.sh --type instance --env $ENV --appName ${CUST_APP_NAME}
    popd
fi

sudo /etc/init.d/supervisor start

#-------------------------------------------------------------------------------
# enable logging
#-------------------------------------------------------------------------------
cd ~/dcStack/logging/ || exit
./i-enable-logging.sh

#-------------------------------------------------------------------------------
# mount volumes and remove instance attached store from /mnt
#-------------------------------------------------------------------------------
cd ~/dcStack/db/postgres/ || exit
sudo sed -i '/\/dev\/xvdb[[:blank:]]\/mnt/d' /etc/fstab
sudo ./i-mount.sh "/media/data/postgres/db" ${ENCRYPT_FS}

#-------------------------------------------------------------------------------
# install postgres and other tasks
#-------------------------------------------------------------------------------
sudo ./postgres.sh "${PGVERSION}" "${DATABASE}" "${VPC_CIDR}"


#-------------------------------------------------------------------------------
# link the db download.sh and restore.sh from dcUtils to the newly recreated
# /media/data/db_restore (created in postgres.sh)
#-------------------------------------------------------------------------------
ln -s $HOME/dcUtils/db/download.sh /media/data/db_restore/
ln -s $HOME/dcUtils/db/restore.sh /media/data/db_restore/

#-------------------------------------------------------------------------------
# restart supervisor to pick up new postgres files in conf.d
#-------------------------------------------------------------------------------
sudo /etc/init.d/supervisor restart

#-------------------------------------------------------------------------------
# get instance type to determine which base postgresql.conf to use
#-------------------------------------------------------------------------------
INSTANCE_TYPE=$(curl http://169.254.169.254/latest/meta-data/instance-type)
if [[ -f ~/dcStack/db/postgres/conf/postgresql.conf.${DCTYPE} ]]; then
    sudo cp ~/dcStack/db/postgres/conf/postgresql.conf."${DCTYPE}" /media/data/postgres/db/pgdata/postgresql.conf
else
    sudo cp ~/dcStack/db/postgres/conf/postgresql.conf /media/data/postgres/db/pgdata/postgresql.conf
fi
sudo chown postgres:postgres /media/data/postgres/db/pgdata/postgresql.conf


#-------------------------------------------------------------------------------
# install pgtune and restart postgres with new config
#-------------------------------------------------------------------------------
if [[ ! -d /media/data/tmp ]]; then
    sudo mkdir /media/data/tmp
fi
sudo chown ubuntu:ubuntu /media/data/tmp
cd /media/data/tmp || exit

# enable ssl
#sudo supervisorctl stop postgres
#sudo sed -i "s/^\bssl\b[[:blank:]]\+=[[:blank:]]\+\bfalse\b/ssl = true/g" /media/data/postgres/db/pgdata/postgresql.conf

#-------------------------------------------------------------------------------
# add parameters in postgresql.conf for wal-e archiving
#-------------------------------------------------------------------------------
function parameter-ensure
{
    P_KEY=$1
    P_VALUE=$2
    P_FILE=$3
    A_DIR=$4
    if (sudo grep -q "^${P_KEY}[[:blank:]]*=" "${P_FILE}"); then
        if ! (sudo grep -q "^${P_KEY}[[:blank:]]*=[[:blank:]]*${P_VALUE}\b" "${P_FILE}"); then
            sudo sed -i "s/${P_KEY}[[:blank:]]*=/#&/g" "${P_FILE}"
            echo "${P_KEY} = ${P_VALUE}"|sudo tee -a "${P_FILE}"
        fi
    else
        echo "${P_KEY} = ${P_VALUE}"|sudo tee -a "${P_FILE}"
    fi
    # need to stick this in a separate file so it can be added if a different postresql.conf overwrites
    # an existing postgresql.conf.  And this new postgresql.conf doesn't have the archive command since we
    # do this step outside of the config.  So, we write out the archive command to a separate file so that
    # this later process can use it just like it is used here.
    # archive_cmd.txt
    echo "${P_KEY} = ${P_VALUE}" >  ${A_DIR}/archive_cmd.txt
}

#-------------------------------------------------------------------------------
# parameter-ensure archive_mode on /media/data/postgres/db/pgdata/postgresql.conf
#-------------------------------------------------------------------------------
parameter-ensure archive_command "'export AWS_REGION=${BACKUP_S3_REGION}; /usr/local/bin/wal-e --aws-instance-profile --s3-prefix s3://${S3_WALE_BUCKET}/${HOSTNAME} wal-push %p'" /media/data/postgres/db/pgdata/postgresql.conf /media/data/tmp
#parameter-ensure archive_timeout 60 /media/data/postgres/db/pgdata/postgresql.conf

#-------------------------------------------------------------------------------
# make copies of files needed for wal-e restore
#-------------------------------------------------------------------------------
sudo cp --preserve /media/data/postgres/db/pgdata/postgresql.conf /media/data/postgres/backup/
sudo cp --preserve /media/data/postgres/db/pgdata/pg_ident.conf /media/data/postgres/backup/
sudo cp --preserve /media/data/postgres/db/pgdata/pg_hba.conf /media/data/postgres/backup/

## create postgresql.conf file with archive mode = off for wal-e restores
#sudo cp --preserve /media/data/postgres/backup/postgresql.conf /media/data/postgres/backup/postgresql.conf.wale
#sudo sed -i "s/^\barchive_mode\b[[:blank:]]\+=[[:blank:]]\+\bon\b/archive_mode = off/g" /media/data/postgres/backup/postgresql.conf.wale

#-------------------------------------------------------------------------------
# self-signed cert for now...
#-------------------------------------------------------------------------------
sudo openssl req -new -x509 -nodes -out /media/data/postgres/db/pgdata/server.crt -keyout /media/data/postgres/db/pgdata/server.key -days 1024 -subj "/C=US"
sudo chmod 0600 /media/data/postgres/db/pgdata/server.key
sudo chown postgres:postgres /media/data/postgres/db/pgdata/server.crt /media/data/postgres/db/pgdata/server.key

sudo supervisorctl restart postgres

#-------------------------------------------------------------------------------
# enable backups
#-------------------------------------------------------------------------------
cd ~/dcStack/db/postgres-backup/ || exit
./enable-backup.sh "${PROFILE}" "${S3_BACKUP_BUCKET}" "${BACKUP_S3_REGION}" "${ENCRYPT_FS}"

#-------------------------------------------------------------------------------
# create wal-e bucket if it doesn't exist
#-------------------------------------------------------------------------------
if ! s3cmd ls s3://"${S3_WALE_BUCKET}" > /dev/null 2>&1; then
    s3cmd --bucket-location=${BACKUP_S3_REGION} mb s3://"${S3_WALE_BUCKET}"
    if [[ ${ENCRYPT_FS} == "true" ]]; then
        # create a json string that represents the structure needed to define the
        # default encryption for the S3 bucket
        ENCRYPT_JSON='{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
        aws --region ${BACKUP_S3_REGION} s3api put-bucket-encryption --bucket "${S3_WALE_BUCKET}" --server-side-encryption-configuration ${ENCRYPT_JSON}
    fi
fi

#-------------------------------------------------------------------------------
# create backup-push file
#-------------------------------------------------------------------------------
NEWBACKUPDIR="/media/data/postgres/backup/wal-e-backups"
if [ ! -d ${NEWBACKUPDIR} ]; then
    sudo mkdir -m 777 ${NEWBACKUPDIR}
fi
echo "export TMPDIR=${NEWBACKUPDIR}" | sudo tee /media/data/postgres/backup/backup-push.sh > /dev/null
echo "export AWS_REGION=${BACKUP_S3_REGION}; /usr/local/bin/wal-e --aws-instance-profile --s3-prefix s3://${S3_WALE_BUCKET}/${HOSTNAME} backup-push /media/data/postgres/db/pgdata" | sudo tee -a /media/data/postgres/backup/backup-push.sh > /dev/null
echo "export AWS_REGION=${BACKUP_S3_REGION}; /usr/local/bin/wal-e --aws-instance-profile --s3-prefix s3://${S3_WALE_BUCKET}/${HOSTNAME} delete --confirm retain 30" | sudo tee -a /media/data/postgres/backup/backup-push.sh > /dev/null
sudo chmod +x /media/data/postgres/backup/backup-push.sh
sudo chown postgres:postgres /media/data/postgres/backup/backup-push.sh

#-------------------------------------------------------------------------------
# push the first wal-e archive to s3
#-------------------------------------------------------------------------------
sudo su -c "/media/data/postgres/backup/backup-push.sh" -s /bin/sh postgres
#sudo su -c "/usr/local/bin/wal-e --aws-instance-profile --s3-prefix s3://${S3_WALE_BUCKET}/${HOSTNAME} backup-push /media/data/postgres/db/pgdata" -s /bin/sh postgres

#-------------------------------------------------------------------------------
# run a nightly wal-e backup
#-------------------------------------------------------------------------------
if ! (sudo crontab -l -u postgres|grep '^[^#].*backup-push.sh\b.*'); then
    (sudo crontab -u postgres -l 2>/dev/null; echo "01 01  *   *   *     /media/data/postgres/backup/backup-push.sh") | sudo crontab -u postgres -
fi

# edit pg_hba.conf to set up appropriate access security for external connections.
# NEED TO CHANGE CONFIG.SH TO NOT ADD INSECURE OPTIONS TO THE FILE
#host replication postgres <VPC SUBNET?> trust
#hostssl <DB NAME> all 0.0.0.0/0 password

#-------------------------------------------------------------------------------
# run the appliction specific web_commands.sh 
#-------------------------------------------------------------------------------
STANDARD_APP_UTILS_DIR="/app-utils/conf"
if [[ -e "${STANDARD_APP_UTILS_DIR}/db-commands.sh" ]]; then
    cd ${STANDARD_APP_UTILS_DIR}
    sudo ./db-commands.sh ${DCTYPE} ${ROLE}
fi

#-------------------------------------------------------------------------------
# Now that the database is running lets create the users database
#-------------------------------------------------------------------------------
sudo -u postgres createdb ${DATABASE,,}
