#!/bin/bash

sudo apt-fast -y install ncdu ntp fail2ban

sudo add-apt-repository -y ppa:tualatrix/ppa
sudo apt-fast update
sudo apt-fast -y install ubuntu-tweak
