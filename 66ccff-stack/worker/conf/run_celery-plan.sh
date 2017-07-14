#!/bin/sh
 
# This script is run by Supervisor to start celery in foreground mode

# Create the socket directories, if it doesn't already exist.
 
if [ ! -d /var/run/celery ]; then
    sudo mkdir /var/run/celery
    sudo chown celery:celery /var/run/celery
fi


# Create a worker for all queues
sudo -Eu celery /usr/local/opt/python/bin/python manage.py celery worker \
                                           --loglevel=INFO --soft-time-limit=36000  \
                                           -c 6 -Q plangeneratorqueue \
                                           -n plan_generator@%n \
                                           --pidfile=/var/run/celery/plan_generator.pid
