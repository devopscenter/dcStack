#!/bin/bash

# Called at creation time for instances or containers (e.g. docker compose)

# override environment variable, if passed via argument
if [[ -n $1 ]]; then
    PAPERTRAIL_ADDRESS=$1
fi

echo "Papertrail destination -> " $PAPERTRAIL_ADDRESS

PAPERTRAIL_SERVER=$(echo "$PAPERTRAIL_ADDRESS"|awk -F':' '{print $1}')
PAPERTRAIL_PORT=$(echo "$PAPERTRAIL_ADDRESS"|awk -F':' '{print $2}')

# Tell rsyslogd where to find papertrail
# filename starts with "95" so that it is the last config file loaded.
if [[ ! -f /etc/rsyslog.d/95-papertrail.conf ]]; then
echo "*.* @${PAPERTRAIL_ADDRESS}" | sudo tee /etc/rsyslog.d/95-papertrail.conf > /dev/null
fi

# restart rsyslog, in order to utilize new config
sudo /etc/init.d/rsyslog restart

# replace PAPERTRAIL_SERVER and PAPERTRAIL_PORT with actual values, if they are in the supervisor config file
# otherwise they'll be passed into the plugin via the environment.
if [[ -f /etc/supervisor/supervisord.conf ]]; then
    sudo sed -i "s/PAPERTRAIL_SERVER/${PAPERTRAIL_SERVER}/" /etc/supervisor/supervisord.conf
    sudo sed -i "s/PAPERTRAIL_PORT/${PAPERTRAIL_PORT}/" /etc/supervisor/supervisord.conf
fi

# Finally, restart rsyslogd and supervisor
sudo /etc/init.d/rsyslog restart
sudo /etc/init.d/supervisor restart
