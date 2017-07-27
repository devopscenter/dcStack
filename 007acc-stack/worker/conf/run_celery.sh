#!/bin/sh
 
# This script is run by Supervisor to start celery in foreground mode

# Create the socket directories, if it doesn't already exist.
 
if [ ! -d /var/run/celery ]; then
    sudo mkdir /var/run/celery
    sudo chown celery:celery /var/run/celery
fi


# Create a worker for all queues
sudo -Eu celery /usr/local/opt/python/bin/celery worker -A rmsasite \
                                           --loglevel=INFO --soft-time-limit=3600  \
                                           -c 4 \
                                           -Ofair \
                                           --pidfile=/var/run/celery/pdf_printer.pid
