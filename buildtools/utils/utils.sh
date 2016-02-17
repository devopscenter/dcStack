#!/bin/bash

sudo apt-fast -y install ncdu ntp fail2ban htop

#sudo add-apt-repository -y ppa:tualatrix/ppa
#sudo apt-fast update
#sudo apt-fast -y install ubuntu-tweak

echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
sudo apt-fast -y install unattended-upgrades
