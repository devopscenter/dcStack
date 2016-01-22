#!/bin/bash

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
# MANUALLY ADD PAPERTRAIL SERVERS TO THIS FILE

if [[ -f /etc/supervisor/conf.d/rsyslogd.conf ]]; then
  sudo rm /etc/supervisor/conf.d/rsyslogd.conf
fi
sudo /etc/init.d/supervisor restart
