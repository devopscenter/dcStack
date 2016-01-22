#!/bin/bash
PRIVATE_IP=$1

# add private IP to /etc/hosts
if ! (grep -q "^${PRIVATE_IP}\b.*\bpostgresmaster_1\b" /etc/hosts); then
  sudo echo "${PRIVATE_IP} postgresmaster_1" >> /etc/hosts
fi

# mount volumes and remove instance attached store from /mnt
./docker-stack/db/postgres/mount.sh
sudo sed '/\/dev\/xvdb[[:blank:]]\/mnt/d' /etc/fstab

# install postgres and other tasks
./docker-stack/db/postgres/postgres.sh

# install pgtune and restart postgres with new config
if [[ ! -d /media/data/tmp ]]; then
  sudo mkdir /media/data/tmp
fi
sudo chown ubuntu:ubuntu /media/data/tmp
cd /media/data/tmp

sudo apt-get install pgtune
sudo pgtune -i /media/data/postgres/db/pgdata/postgresql.conf -o postgresql.conf.pgtune
sudo cp postgresql.conf.pgtune /media/data/postgres/db/pgdata/postgresql.conf
sudo supervisorctl restart postgres
