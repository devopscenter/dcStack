#!/bin/bash -e

#
# App-specific worker install for 007ACC
#
COMBINED_WEBANDWORKER=$1

echo "Begin: install of customer-specific worker, combo: ",COMBINED_WEBANDWORKER

sudo useradd celery

#
# If this is purely a worker, then we don't need ngix or uwsgi
#

if [[ ! $COMBINED_WEBANDWORKER ]]; then
    sudo rm -rf /etc/supervisor/conf.d/uwsgi.conf
    sudo rm -rf /etc/supervisor/conf.d/run_uwsgi.conf
    sudo rm -rf /etc/supervisor/conf.d/nginx.conf
fi

# Required directories for f2
sudo mkdir -p /data/deploy /data/media /data/scratch 
sudo chown celery:celery /data/scratch 

sudo cp app-conf/supervisor-flower.conf /etc/supervisor/conf.d/flower.conf 
sudo cp app-conf/supervisor-celery.conf /etc/supervisor/conf.d/celery.conf
sudo cp app-conf/run_celery.sh /etc/supervisor/conf.d/run_celery.sh


echo "End: install of customer-specific worker, combo: ", COMBINED_WEBANDWORKER
