#!/bin/sh
 
# This script is run by Supervisor to start celery in foreground mode

# Create the socket directories, if it doesn't already exist.
 
if [ ! -d /var/run/celery ]; then
    sudo install -d -m 755 -o celery -g celery /var/run/celery
fi


# Create a worker for all queues
/usr/local/opt/python/bin/python manage.py celery worker \
                                           --loglevel=INFO --soft-time-limit=300  \
                                           -c 4 -Q pdfprinttaskqueue,plangeneratorqueue,processhistoryqueue,processmidmonthqueue \
                                           -n pdf_printer@%n \
                                           --pidfile=/var/run/celery/pdf_printer-pdf_printer.pid
