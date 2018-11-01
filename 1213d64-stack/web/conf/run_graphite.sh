#!/bin/bash
export GRAPHITE_WSGI_PROCESSES=${GRAPHITE_WSGI_PROCESSES:-4}
export GRAPHITE_WSGI_THREADS=${GRAPHITE_WSGI_THREADS:-2}
export GRAPHITE_WSGI_REQUEST_TIMEOUT=${GRAPHITE_WSGI_REQUEST_TIMEOUT:-65}
export GRAPHITE_WSGI_REQUEST_LINE=${GRAPHITE_WSGI_REQUEST_LINE:-0}
export GRAPHITE_WSGI_MAX_REQUESTS=${GRAPHITE_WSGI_MAX_REQUESTS:-1000}
exec /usr/local/opt/python/bin/gunicorn wsgi --preload --pythonpath=/opt/graphite/webapp/graphite \
    --workers=${GRAPHITE_WSGI_PROCESSES} \
    --threads=${GRAPHITE_WSGI_THREADS} \
    --limit-request-line=${GRAPHITE_WSGI_REQUEST_LINE} \
    --max-requests=${GRAPHITE_WSGI_MAX_REQUESTS} \
    --timeout=${GRAPHITE_WSGI_REQUEST_TIMEOUT} \
    --bind=0.0.0.0:8000 \
    --log-syslog
