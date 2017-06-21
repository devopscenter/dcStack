#!/bin/bash -e

# Assumes that this is being installed on top of a dcStack web proto
# (supervisor, base-utils, python, etc)

set -x

# prevent services from starting automatically after package install
echo -e '#!/bin/bash\nexit 101' | sudo tee /usr/sbin/policy-rc.d
sudo chmod +x /usr/sbin/policy-rc.d

sudo addgroup jenkins
sudo adduser jenkins --ingroup jenkins

# install jenkins
wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get -y install jenkins

# configure jenkins with new home dir
sudo mkdir -p /media/data/jenkins
sudo chown -R jenkins:jenkins /media/data/jenkins
sudo usermod -d /media/data/jenkins jenkins
echo "JENKINS_HOME=/media/data/jenkins" | sudo tee -a /etc/default/jenkins

# copy the configs for running jenkins
sudo cp -a conf/program_jenkins.conf /etc/supervisor/conf.d/program_jenkins.conf
sudo cp -a conf/run_jenkins.sh /etc/supervisor/conf.d/run_jenkins.sh

# install grunt-cli
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g grunt-cli

# start/restart supervisor to start jenkins
sudo /etc/init.d/supervisor restart
