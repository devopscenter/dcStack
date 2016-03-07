#!/bin/bash

PAPERTRAIL_ADDRESS=$1
PAPERTRAIL_SERVER=$(echo "$PAPERTRAIL_ADDRESS"|awk -F':' '{print $1}')
PAPERTRAIL_PORT=$(echo "$PAPERTRAIL_ADDRESS"|awk -F':' '{print $2}')

# note that this is only run on an instance, not within a container.

# enable logging with papertrail using rsyslogd
if [[ ! -f /etc/rsyslog.d/papertrail.conf ]]; then
  echo "*.* @${PAPERTRAIL_ADDRESS}" | sudo tee /etc/rsyslog.d/papertrail.conf > /dev/null
fi

# comment out broken section of this file and restart rsyslog
# https://bugs.launchpad.net/ubuntu/+source/rsyslog/+bug/830046
sudo cp "50-default.conf" /etc/rsyslog.d/50-default.conf
sudo service rsyslog restart

# install the supervisor-syslog plugin, update conf file,
# remove conflicting rsyslog file, and finally restart supervisor
# https://github.com/Supervisor/supervisor/issues/446
sudo pip install supervisor-logging
sudo cp "supervisord.conf" /etc/supervisor/supervisord.conf

# replace PAPERTRAIL_SERVER and PAPERTRAIL_PORT with actual values
sudo sed -i "s/PAPERTRAIL_SERVER/${PAPERTRAIL_SERVER}/" /etc/supervisor/supervisord.conf
sudo sed -i "s/PAPERTRAIL_PORT/${PAPERTRAIL_PORT}/" /etc/supervisor/supervisord.conf

if [[ -f /etc/supervisor/conf.d/rsyslogd.conf ]]; then
  sudo rm /etc/supervisor/conf.d/rsyslogd.conf
fi
sudo /etc/init.d/supervisor restart
