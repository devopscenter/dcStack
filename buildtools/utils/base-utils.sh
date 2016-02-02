#!/bin/bash
sudo apt-get -qq update && sudo apt-get -qq -y install python-software-properties software-properties-common && \
    sudo add-apt-repository "deb http://gb.archive.ubuntu.com/ubuntu $(lsb_release -sc) universe" && \
    sudo apt-get -qq update

sudo add-apt-repository -y ppa:saiarcot895/myppa && \
    sudo apt-get -qq update && \
    sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y install apt-fast

sudo apt-fast -qq -y install git python-dev python-pip wget sudo vim supervisor awscli

sudo apt-fast -y install ncdu ntp fail2ban htop

#sudo add-apt-repository -y ppa:tualatrix/ppa
#sudo apt-fast update
#sudo apt-fast -y install ubuntu-tweak

echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | sudo debconf-set-selections
sudo apt-fast -y install unattended-upgrades
