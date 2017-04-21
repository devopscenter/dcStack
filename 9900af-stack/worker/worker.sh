#!/bin/bash -e

COMBINED_WEB_WORKER="${1}"

source /usr/local/bin/dcEnv.sh                       # initalize logging environment
dcStartLog "install of app-specific worker for 9900af, combo: ${COMBINED_WEB_WORKER}"

#
# If this is purely a worker, then we don't need nginx and uwsgi
#

if [[ "${COMBINED_WEB_WORKER}" = "false" ]]; then
    sudo rm -rf /etc/supervisor/conf.d/uwsgi.conf
    sudo rm -rf /etc/supervisor/conf.d/run_uwsgi.conf
    sudo rm -rf /etc/supervisor/conf.d/nginx.conf 
fi

#
# Setup supervisor to run django-rq worker(s)
#
cp conf/supervisor-djangorq-worker.conf /etc/supervisor/conf.d/djangorq-worker.conf

dcEndLog "install of app-specific worker for 9900af, combo: ${COMBINED_WEB_WORKER}"
