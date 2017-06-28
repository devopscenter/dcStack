#!/bin/bash -e

# Assumes that this is being installed on top of a dcStack web proto
# (supervisor, base-utils, python, etc)

# Create jenkins user and the new default directory.
sudo useradd jenkins

sudo mkdir -p /media/data/jenkins
sudo chown -R jenkins:jenkins /media/data/jenkins

sudo usermod -d /media/data/jenkins jenkins

# install jenkins
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get -y install jenkins

echo "JENKINS_HOME=/media/data/jenkins" | sudo tee -a /etc/default/jenkins
echo "AWS_KEYS=/media/data/jenkins/.ssh" | sudo tee -a /etc/defaults/jenkins

# copy the configs for running jenkins
sudo cp -a conf/program_jenkins.conf /etc/supervisor/conf.d/program_jenkins.conf
sudo cp -a conf/run_jenkins.sh /etc/supervisor/conf.d/run_jenkins.sh

# install grunt-cli
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g grunt-cli

# prevent services from starting automatically after package install
# stop the systemd jenkins so that it can be disabled and removed
sudo service jenkins stop

#disable init.d autostart
sudo update-rc.d jenkins disable

# start/restart supervisor to start jenkins
sudo /etc/init.d/supervisor restart
