#!/bin/bash

PRIVATE_IP=$1
PAPERTRAIL_ADDRESS=$2
VPC_CIDR=$3
DATABASE=$4
S3_BACKUP_BUCKET=$5
S3_WALE_BUCKET=$6

if [[ -z $PRIVATE_IP ]] || [[ -z $PAPERTRAIL_ADDRESS ]]; then
  echo "usage: new_postgres.sh <private ip address> <papertrailurl:port>"
  exit 1
fi

# install standard packages/utilities
cd ~/docker-stack/buildtools/utils/ || exit
sudo ./base-utils.sh

# add private IP to /etc/hosts
if ! (grep -q "^${PRIVATE_IP}\b.*\bpostgresmaster_1\b" /etc/hosts); then
  echo "${PRIVATE_IP} postgresmaster_1" | sudo tee -a /etc/hosts > /dev/null
fi

# mount volumes and remove instance attached store from /mnt
cd ~/docker-stack/db/postgres/ || exit
sudo ./mount.sh
sudo sed '/\/dev\/xvdb[[:blank:]]\/mnt/d' /etc/fstab

# install postgres and other tasks
sudo ./postgres.sh "${VPC_CIDR}" "${DATABASE}"

# install pgtune and restart postgres with new config
if [[ ! -d /media/data/tmp ]]; then
  sudo mkdir /media/data/tmp
fi
sudo chown ubuntu:ubuntu /media/data/tmp
cd /media/data/tmp || exit

# update postgresql.conf with pgtuned parameters
sudo apt-fast -y install pgtune
sudo pgtune -i /media/data/postgres/db/pgdata/postgresql.conf -o postgresql.conf.pgtune
sudo cp postgresql.conf.pgtune /media/data/postgres/db/pgdata/postgresql.conf
sudo supervisorctl restart postgres

# enable logging
cd ~/docker-stack/logging/ || exit
./enable-pg-logging.sh "$PAPERTRAIL_ADDRESS"

# enable ssl
sudo supervisorctl stop postgres
sudo sed -i "s/^\bssl\b[[:blank:]]\+=[[:blank:]]\+\bfalse\b/ssl = true/g" /media/data/postgres/db/pgdata/postgresql.conf

# add parameters in postgresql.conf for wal-e archiving
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
parameter-ensure archive_mode on /media/data/postgres/db/pgdata/postgresql.conf
parameter-ensure archive_command "'wal-e --aws-instance-profile --s3-prefix s3://${S3_WALE_BUCKET} wal-push %p'" /media/data/postgres/db/pgdata/postgresql.conf
# /media/data/postgres/db/xlog/transactions
maybe using the wrong parameters, due to sourcing pgenv or whatever
parameter-ensure archive_timeout 60 /media/data/postgres/db/pgdata/postgresql.conf

# self-signed cert for now...
sudo openssl req -new -x509 -nodes -out /media/data/postgres/db/pgdata/server.crt -keyout /media/data/postgres/db/pgdata/server.key -days 1024 -subj "/C=US"
sudo chmod 0600 /media/data/postgres/db/pgdata/server.key
sudo chown postgres:postgres /media/data/postgres/db/pgdata/server.crt /media/data/postgres/db/pgdata/server.key

sudo supervisorctl restart postgres

cd ~/docker-stack/db/postgres-backup/ || exit
./enable-backup.sh "$S3_BACKUP_BUCKET"

# push the first wal-e archive to s3
sudo su -c "wal-e --aws-instance-profile --s3-prefix s3://${S3_WALE_BUCKET} backup-push /media/data/postgres/db/pgdata" -s /bin/sh postgres

# edit pg_hba.conf to set up appropriate access security for external connections.
# NEED TO CHANGE CONFIG.SH TO NOT ADD INSECURE OPTIONS TO THE FILE
#host replication postgres <VPC SUBNET?> trust
#hostssl <DB NAME> all 0.0.0.0/0 password


# set postgres user password
#?
