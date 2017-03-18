#!/bin/bash -e
set -x

#
# One time installation tasks for a 66CCFF worker
#
COMBINED_WEBANDWORKER=$1

sudo useradd celery

#
# Install libs that were apparently removed in ubuntu 16.04
#
sudo apt-get install libfontconfig1 libxrender1


#
# If this is purely a worker, then we don't need uwsgi (F1 still requires nginx, though with a specialized config)
#

if [[ ! $COMBINED_WEBANDWORKER ]]; then
    sudo rm -rf /etc/supervisor/conf.d/uwsgi.conf
    sudo rm -rf /etc/supervisor/conf.d/run_uwsgi.conf
    sudo cp conf/nginx.conf /usr/local/nginx/conf/nginx.conf
fi

# 
# Required directories for this app
#
sudo mkdir -p /data/deploy /data/media /data/media/pdfcreator /data/media/reports/pdf /data/scratch 
sudo chown celery:celery /data/media/pdfcreator /data/media/reports /data/media/reports/pdf /data/scratch 

sudo cp conf/supervisor-flower.conf /etc/supervisor/conf.d/flower.conf 
sudo cp conf/supervisor-celery.conf /etc/supervisor/conf.d/celery.conf
sudo cp conf/run_celery.sh /etc/supervisor/conf.d/run_celery.sh

