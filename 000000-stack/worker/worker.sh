#!/bin/bash -e

source /usr/local/bin/dcEnv.sh                       # initalize logging environment
dcStartLog "install of app-specific worker for 000000"

#
# If this is purely a worker, then we don't need uwsgi (this app still requires nginx, though with a specialized config)
#

if [[ "${COMBINED_WEB_WORKER}" = "true" ]]; then
    sudo cp conf/nginx-combo.conf /usr/local/nginx/conf/nginx.conf
elif [[ "${COMBINED_WEB_WORKER}" = "false" ]]; then
    sudo rm -rf /etc/supervisor/conf.d/uwsgi.conf
    sudo rm -rf /etc/supervisor/conf.d/run_uwsgi.conf
    sudo rm -rf /etc/supervisor/conf.d/nginx.conf 
fi

#
# Setup supervisor to run django-rq worker(s)
#
cp conf/supervisor-djangorq-worker.conf /etc/supervisor/conf.d/djangorq-worker.conf


dcEndLog "install of app-specific worker for 000000"