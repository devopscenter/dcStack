#!/bin/sh
 
# This script is run by Supervisor to start UWSGI in foreground mode

# Create the socket directory, if it doesn't already exist.
 
if [ ! -e /var/run/uwsgi ]; then
    sudo install -d -m 755 -o uwsgi /var/run/uwsgi
fi

if [ -e /tmp/uwsgififo ]; then
    sudo rm /tmp/uwsgififo
fi

exec /usr/local/opt/python/bin/uwsgi \
        --enable-threads \
        --master-fifo /tmp/uwsgififo \
        --workers=${UWSGI_WORKERS} \
        --max-requests=${UWSGI_MAX_REQUESTS} \
        --lazy-apps \
        --hook-post-fork="chdir:/data/deploy/current" \
        /data/deploy/current/uwsgi.ini
