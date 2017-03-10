#!/bin/bash -e
set -x

sudo useradd celery

# Required directories for f1
sudo mkdir -p /data/deploy /data/media /data/media/pdfcreator /data/media/reports/pdf /data/scratch 
sudo chown celery:celery /data/media/pdfcreator /data/media/reports /data/media/reports/pdf /data/scratch 

cp app-conf/supervisor-flower.conf /etc/supervisor/conf.d/flower.conf 
cp app-conf/supervisor-celery.conf /etc/supervisor/conf.d/celery.conf
cp app-conf/run_celery.sh /etc/supervisor/conf.d/run_celery.sh

