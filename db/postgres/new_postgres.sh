#!/bin/bash

PRIVATE_IP=$1
PAPERTRAIL_ADDRESS=$2
VPC_CIDR=$3
DATABASE=$4
S3_BUCKET=$5

if [[ -z $PRIVATE_IP ]] || [[ -z $PAPERTRAIL_ADDRESS ]]; then
  echo "usage: new_postgres.sh <private ip address> <papertrailurl:port>"
  exit 1
fi

# install standard packages/utilities
cd ../../buildtools/utils/
sudo ./base-utils.sh

# add private IP to /etc/hosts
if ! (grep -q "^${PRIVATE_IP}\b.*\bpostgresmaster_1\b" /etc/hosts); then
  echo "${PRIVATE_IP} postgresmaster_1" | sudo tee -a /etc/hosts > /dev/null
fi

# mount volumes and remove instance attached store from /mnt
cd ../../db/postgres/
sudo ./mount.sh
sudo sed '/\/dev\/xvdb[[:blank:]]\/mnt/d' /etc/fstab

# install postgres and other tasks
sudo ./postgres.sh "${VPC_CIDR}" "${DATABASE}"

# install pgtune and restart postgres with new config
if [[ ! -d /media/data/tmp ]]; then
  sudo mkdir /media/data/tmp
fi
sudo chown ubuntu:ubuntu /media/data/tmp
cd /media/data/tmp

sudo apt-fast -y install pgtune
sudo pgtune -i /media/data/postgres/db/pgdata/postgresql.conf -o postgresql.conf.pgtune
sudo cp postgresql.conf.pgtune /media/data/postgres/db/pgdata/postgresql.conf
sudo supervisorctl restart postgres

# enable logging
cd ~/docker-stack/logging/
./enable-pg-logging.sh "$PAPERTRAIL_ADDRESS"

# enable ssl
sudo supervisorctl stop postgres
sudo sed -i "s/^\bssl\b[[:blank:]]\+=[[:blank:]]\+\bfalse\b/ssl = true/g" /media/data/postgres/db/pgdata/postgresql.conf

# self-signed cert for now...
sudo openssl req -new -x509 -nodes -out /media/data/postgres/db/pgdata/server.crt -keyout /media/data/postgres/db/pgdata/server.key -days 1024 -subj "/C=US"
sudo chmod 0600 /media/data/postgres/db/pgdata/server.key
sudo chown postgres:postgres /media/data/postgres/db/pgdata/server.crt /media/data/postgres/db/pgdata/server.key

sudo supervisorctl restart postgres

cd ~/docker-stack/db/postgres-backup/
./enable-backup.sh "$S3_BUCKET"

# edit pg_hba.conf to set up appropriate access security for external connections.
# NEED TO CHANGE CONFIG.SH TO NOT ADD INSECURE OPTIONS TO THE FILE
#host replication postgres <VPC SUBNET?> trust
#hostssl <DB NAME> all 0.0.0.0/0 password


# set postgres user password
#?
