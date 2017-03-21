#!/bin/bash - 
#===============================================================================
#
#          FILE: worker.sh
# 
#         USAGE: worker/worker.sh  COMBINED_WEBANDWORKER
# 
#   DESCRIPTION: 66CCFF stack, install worker-specific components.
# 
#       OPTIONS: if COMBINED_WEBANDWORKER="true", then web and worker on a single instance/container; otherwise, separate instances/containers.
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Bob Lozano, bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: long time ago
#      REVISION:  ---
#===============================================================================

#set -o nounset                             # Treat unset variables as an error

source ../../dcEnv.sh                       # initalize logging environment

COMBINED_WEBANDWORKER=$1

dcStartLog "install of customer-specific worker, combo: ${COMBINED_WEBANDWORKER}"

sudo useradd celery

#
# If this is purely a worker, then we don't need uwsgi (this app still requires nginx, though with a specialized config)
#

if [[ ! "${COMBINED_WEBANDWORKER}" = "true" ]]; then
    sudo rm -rf /etc/supervisor/conf.d/uwsgi.conf
    sudo rm -rf /etc/supervisor/conf.d/run_uwsgi.conf
    sudo cp conf/nginx.conf /usr/local/nginx/conf/nginx.conf
fi

# 
# Required directories for this app
#
sudo mkdir -p /data/deploy /data/media /data/media/pdfcreator /data/media/reports/pdf /data/scratch 
sudo chown celery:celery /data/media/pdfcreator /data/media/reports /data/media/reports/pdf /data/scratch 

#
# Setup supervisor to run flower and celery
#
sudo cp conf/supervisor-flower.conf /etc/supervisor/conf.d/flower.conf 
sudo cp conf/supervisor-celery.conf /etc/supervisor/conf.d/celery.conf
sudo cp conf/run_celery.sh /etc/supervisor/conf.d/run_celery.sh


dcEndLog "install of customer-specific worker, combo: ${COMBINED_WEBANDWORKER}"

