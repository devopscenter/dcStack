#!/bin/bash

# Install supervisor 3.2.3 via pip install, and mimic installation structure and configs of apt-get install.
# Must be run after python and it's pip is installed.

sudo pip install supervisor
export PATH="/usr/local/opt/python/bin:${PATH}"

sudo mkdir /etc/supervisor
sudo mkdir /etc/supervisor/conf.d
sudo mkdir /var/log/supervisor
sudo cp ~/docker-stack/buildtools/utils/initd-supervisor /etc/init.d/supervisor
sudo cp ~/docker-stack/buildtools/utils/supervisord.conf /etc/supervisor/

# Now make sure that it starts up upon reboot
sudo update-rc.d supervisor defaults
