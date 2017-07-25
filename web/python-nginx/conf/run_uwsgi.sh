#!/bin/sh
 
# This script is run by Supervisor to start UWSGI in foreground mode

# Create the socket directory, if it doesn't already exist.
 
if [ ! -e /var/run/uwsgi ]; then
    sudo install -d -m 755 -o uwsgi /var/run/uwsgi
fi

exec /usr/local/opt/python/bin/uwsgi \
        --enable-threads \
        --master-fifo /tmp/uwsgififo \
        --lazy-apps \
        --hook-post-fork="chdir:/data/deploy/current" \
        /data/deploy/current/uwsgi.ini
