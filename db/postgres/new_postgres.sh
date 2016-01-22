#!/bin/bash
PRIVATE_IP=$1

# install standard packages/utilities
cd ../../buildtools/utils/
sudo ./base-utils

# add private IP to /etc/hosts
if ! (grep -q "^${PRIVATE_IP}\b.*\bpostgresmaster_1\b" /etc/hosts); then
  echo "${PRIVATE_IP} postgresmaster_1" | tee -a /etc/hosts > /dev/null
fi

# mount volumes and remove instance attached store from /mnt
cd ../../db/postgres/
sudo ./mount.sh
sudo sed '/\/dev\/xvdb[[:blank:]]\/mnt/d' /etc/fstab

# install postgres and other tasks
sudo ./postgres.sh

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
./enable-pg-logging.sh
