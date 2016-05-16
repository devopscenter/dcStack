#!/bin/bash

# All 5 arguments are required

PRIVATE_IP=$1
PAPERTRAIL_ADDRESS=$2
STACK=$3
SUFFIX=$4
ENV=$5
PGVERSION=$6

if [[ -z $PRIVATE_IP ]] || [[ -z $PAPERTRAIL_ADDRESS ]]; then
  echo "usage: new_postgres.sh <private ip address> <papertrailurl:port>"
  exit 1
fi

# install standard packages/utilities
cd ~/docker-stack/buildtools/utils/ || exit
sudo ./base-utils.sh

# install stack common to web and workers
cd ~/docker-stack/python/ || exit
sudo ./python.sh

cd ~/docker-stack/buildtools/utils || exit
sudo ./install-supervisor.sh custom

# enable logging
cd ~/docker-stack/logging/ || exit
./enable-logging.sh "$PAPERTRAIL_ADDRESS"

cd ~/docker-stack/web/python-nginx/ || exit
sudo ./nginx.sh

cd ~/docker-stack/web/python-nginx-pgpool/ || exit
sudo ./pgpool.sh "$PGVERSION"

cd ~/docker-stack/web/python-nginx-pgpool-redis/ || exit
sudo ./redis-client-install.sh


# Install customer-specific stack - all get the web portion.

cd ~/docker-stack/${STACK}-stack/web/ || exit
sudo ./web.sh

if [[ "$SUFFIX" = "worker" ]]; then
  cd ~/docker-stack/${STACK}-stack/worker/ || exit
  sudo ./worker.sh
fi

# Fix configuration files, using env vars distributed in the customer-specific (and private) utils.

if [[ (-n "${ENV}") && (-e ~/utils/environments) ]]; then
  ~/utils/environments/deployenv.sh $SUFFIX $ENV
fi

# Restart supervisor, so that all services are now running.

if !(sudo /etc/init.d/supervisor restart); then
  echo "Error somewhere in supervisor or one of the services started by supervisor"
fi
