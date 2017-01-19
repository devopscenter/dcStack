#!/bin/bash

echo "i-enable-logging.sh"
echo "full env $(env)"
echo "SYSLOG_SERVER=${SYSLOG_SERVER}"
echo "SYSLOG_PORT=${SYSLOG_PORT}"
echo "SYSLOG_PROTO=${SYSLOG_PROTO}"

PAPERTRAIL_ADDRESS=$1
PAPERTRAIL_SERVER=$(echo "$PAPERTRAIL_ADDRESS"|awk -F':' '{print $1}')
PAPERTRAIL_PORT=$(echo "$PAPERTRAIL_ADDRESS"|awk -F':' '{print $2}')

# note that this is only run on an instance, not within a container.
# also, must be run after supervisor is installed.

# Enable logging to papertrail through rsyslogd, using TLS and queueing
./papertrail.sh

# Set the papertrail destination in rsyslogd and supervisor.
./set-destination.sh $PAPERTRAIL_ADDRESS

