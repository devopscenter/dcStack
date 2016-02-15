#!/bin/bash -ev

sudo apt-fast -y install rsyslog-gnutls
sudo curl -o /etc/papertrail-bundle.pem https://papertrailapp.com/tools/papertrail-bundle.pem
sudo cp papertrailqueue.conf /etc/rsyslog.d/papertrailqueue.conf

# comment out broken section of this file and restart rsyslog
# https://bugs.launchpad.net/ubuntu/+source/rsyslog/+bug/830046
sudo cp "50-default.conf" /etc/rsyslog.d/50-default.conf
