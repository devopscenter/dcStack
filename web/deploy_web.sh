#!/bin/bash

PRIVATE_IP=$1
PAPERTRAIL_ADDRESS=$2

if [[ -z $PRIVATE_IP ]] || [[ -z $PAPERTRAIL_ADDRESS ]]; then
  echo "usage: new_postgres.sh <private ip address> <papertrailurl:port>"
  exit 1
fi

# install standard packages/utilities
cd ~/docker-stack/buildtools/utils/ || exit
sudo ./base-utils.sh


# install postgres and other tasks
sudo ./postgres.sh "${VPC_CIDR}" "${DATABASE}"


# enable logging
cd ~/docker-stack/logging/ || exit
./enable-pg-logging.sh "$PAPERTRAIL_ADDRESS"


sudo supervisorctl restart postgres
