#!/bin/bash -e

#
# App-specific worker install for 007acc
#
COMBINED_WEB_WORKER="${1}"
SCRATCHVOLUME="{$2}"

source /usr/local/bin/dcEnv.sh                       # initalize logging environment
dcStartLog "install of app-specific worker for 007acc, combo: ${COMBINED_WEB_WORKER}"

sudo useradd celery

#
# If this is purely a worker, then we don't need ngix or uwsgi
#

if [[ "${COMBINED_WEB_WORKER}" = "false" ]]; then
    sudo rm -rf /etc/supervisor/conf.d/uwsgi.conf
    sudo rm -rf /etc/supervisor/conf.d/run_uwsgi.conf
    sudo rm -rf /etc/supervisor/conf.d/nginx.conf
fi

# 
# Required directories for this app
#
if [[ "${SCRATCHVOLUME}" == "true" ]]; then
    sudo mkdir /media/data/scratch

    sudo ln -s /media/data /data/media 
    sudo ln -s /media/data/scratch /data/scratch
else
    # put everything on the root volume
    sudo mkdir -p /data/media/pdfcreator /data/media/reports/pdf /data/scratch 
fi
sudo chown celery:celery /data/scratch 

#
# Setup supervisor to run flower and celery
#
sudo cp conf/supervisor-flower.conf /etc/supervisor/conf.d/flower.conf 
sudo cp conf/supervisor-celery.conf /etc/supervisor/conf.d/celery.conf
sudo cp conf/run_celery.sh /etc/supervisor/conf.d/run_celery.sh


dcEndLog "End: install of customer-specific worker for 007acc, combo: ${COMBINED_WEB_WORKER}"
