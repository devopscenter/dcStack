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

# enable logging
cd ~/docker-stack/logging/ || exit
./enable-logging.sh "$PAPERTRAIL_ADDRESS"

exit 0

# install stack common to web and workers
cd ~/docker-stack/python/ || exit
sudo ./python.sh

cd ~/docker-stack/web/python-nginx/ || exit
sudo ./nginx.sh

cd ~/docker-stack/web/python-nginx-pgpool/ || exit
sudo ./pgpool.sh

cd ~/docker-stack/web/python-nginx-pgpool-redis/ || exit
sudo ./redis-client-install.sh


# Install customer-specific stack


