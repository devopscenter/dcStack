#!/bin/bash

sudo apt-fast -y install ncdu ntp fail2ban htop

#sudo add-apt-repository -y ppa:tualatrix/ppa
#sudo apt-fast update
#sudo apt-fast -y install ubuntu-tweak

sudo apt-fast -y install unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades
