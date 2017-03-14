#!/bin/bash -
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
#        AUTHOR2: Josh, Bob & Trey
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 09/29/2016 09:11:12
#      REVISION:  ---
#===============================================================================
set -vx

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

if  [[ -z "$PRIVATE_IP" ]] ||
    [[ -z "$VPC_CIDR" ]] ||
    [[ -z "$DATABASE" ]] ||
    [[ -z "$S3_BACKUP_BUCKET" ]] ||
    [[ -z "$S3_WALE_BUCKET" ]] ||
    [[ -z "$PGVERSION" ]] ||
    [[ -z "$DCTYPE}" ]] ||
    [[ -z "$ENV" ]]; then

    echo "10 Arguments are required: "
    echo "    PRIVATE_IP: ${PRIVATE_IP}"
    echo "    VPC_CIDR: ${VPC_CIDR}"
    echo "    DATABASE: ${DATABASE}"
    echo "    S3_BACKUP_BUCKET: ${S3_BACKUP_BUCKET}"
    echo "    S3_WALE_BUCKET: ${S3_WALE_BUCKET}"
    echo "    PGVERSION: ${PGVERSION}"
    echo "    DNS_METHOD: ${DNS_METHOD}"
    echo "    ENV: ${ENV}"
    echo "    DCTYPE: ${DCTYPE}"
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
sudo ./i-mount.sh

#-------------------------------------------------------------------------------
# install postgres and other tasks
#-------------------------------------------------------------------------------
sudo ./postgres.sh "${PGVERSION}" "${DATABASE}" "${VPC_CIDR}"

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
    if (sudo grep -q "^${P_KEY}[[:blank:]]*=" "${P_FILE}"); then
        if ! (sudo grep -q "^${P_KEY}[[:blank:]]*=[[:blank:]]*${P_VALUE}\b" "${P_FILE}"); then
            sudo sed -i "s/${P_KEY}[[:blank:]]*=/#&/g" "${P_FILE}"
            echo "${P_KEY} = ${P_VALUE}"|sudo tee -a "${P_FILE}"
        fi
    else
        echo "${P_KEY} = ${P_VALUE}"|sudo tee -a "${P_FILE}"
    fi
}

#-------------------------------------------------------------------------------
# parameter-ensure archive_mode on /media/data/postgres/db/pgdata/postgresql.conf
#-------------------------------------------------------------------------------
parameter-ensure archive_command "'/usr/local/bin/wal-e --aws-instance-profile --s3-prefix s3://${S3_WALE_BUCKET}/${HOSTNAME} wal-push %p'" /media/data/postgres/db/pgdata/postgresql.conf
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
# set postgres user password
#-------------------------------------------------------------------------------
PG_PWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
psql -U postgres -c "ALTER USER Postgres WITH PASSWORD '${PG_PWD}';"
echo "postgres user password: ${PG_PWD}"

cd ~/dcStack/db/postgres-backup/ || exit
./enable-backup.sh "$S3_BACKUP_BUCKET"

#-------------------------------------------------------------------------------
# create wal-e bucket if it doesn't exist
#-------------------------------------------------------------------------------
if ! s3cmd ls s3://"$S3_WALE_BUCKET" > /dev/null 2>&1; then
    s3cmd mb s3://"$S3_WALE_BUCKET"
fi

#-------------------------------------------------------------------------------
# create backup-push file
#-------------------------------------------------------------------------------
NEWBACKUPDIR="/media/data/postgres/backup/wal-e-backups"
if [ ! -d ${NEWBACKUPDIR} ]; then
    sudo mkdir -m 777 ${NEWBACKUPDIR}
fi
echo "export TMPDIR=${NEWBACKUPDIR}" | sudo tee /media/data/postgres/backup/backup-push.sh > /dev/null
echo "/usr/local/bin/wal-e --aws-instance-profile --s3-prefix s3://${S3_WALE_BUCKET}/${HOSTNAME} backup-push /media/data/postgres/db/pgdata" | sudo tee -a /media/data/postgres/backup/backup-push.sh > /dev/null
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
