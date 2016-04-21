#!/bin/sh
 
# This script is run by Supervisor to start UWSGI in foreground mode

# Create the socket directory, if it doesn't already exist.
 
if [ ! -e /var/run/uwsgi ]; then
    install -d -m 2775 -o uwsgi /var/run/uwsgi
fi

exec env -i /usr/local/opt/python/bin/uwsgi --enable-threads /data/deploy/current/uwsgi.ini
