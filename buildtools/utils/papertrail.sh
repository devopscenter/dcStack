#!/bin/bash -ev

sudo apt-fast -y install rsyslog-gnutls
sudo curl -o /etc/papertrail-bundle.pem https://papertrailapp.com/tools/papertrail-bundle.pem
cat papertrail.conf | sudo tee --append /etc/rsyslog.conf
