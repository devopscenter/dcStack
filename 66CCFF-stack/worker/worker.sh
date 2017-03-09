#!/bin/bash -e

sudo useradd celery

# Required directories for f1
sudo mkdir -p /data/deploy /data/media /data/media/pdfcreator /data/media/reports/pdf /data/scratch 
sudo chown celery:celery /data/media/pdfcreator /data/media/reports /data/media/reports/pdf /data/scratch 

cp conf/supervisor-flower.conf /etc/supervisor/conf.d/flower.conf 
cp conf/supervisor-celery.conf /etc/supervisor/conf.d/celery.conf
cp conf/run_celery.sh /etc/supervisor/conf.d/run_celery.sh

