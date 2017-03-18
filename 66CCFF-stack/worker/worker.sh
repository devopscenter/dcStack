#!/bin/bash -e
set -x

COMBINED_WEBANDWORKER=$1

sudo useradd celery

#
# If this is purely a worker, then we don't need uwsgi (F1 still requires nginx, though with a specialized config)
#

if [[ ! COMBINED_WEBANDWORKER ]]; then
    sudo rm -rf /etc/supervisor/conf.d/uwsgi.conf
    sudo rm -rf /etc/supervisor/conf.d/run_uwsgi.conf
    sudo cp conf/nginx.conf /usr/local/nginx/conf/nginx.conf
fi

# Required directories for f1
sudo mkdir -p /data/deploy /data/media /data/media/pdfcreator /data/media/reports/pdf /data/scratch 
sudo chown celery:celery /data/media/pdfcreator /data/media/reports /data/media/reports/pdf /data/scratch 

sudo cp app-conf/supervisor-flower.conf /etc/supervisor/conf.d/flower.conf 
sudo cp app-conf/supervisor-celery.conf /etc/supervisor/conf.d/celery.conf
sudo cp app-conf/run_celery.sh /etc/supervisor/conf.d/run_celery.sh

