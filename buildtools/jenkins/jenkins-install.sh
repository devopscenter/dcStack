#!/usr/bin/env bash
#===============================================================================
#
#          FILE: jenkins-install.sh
#
#         USAGE: jenkins-install.sh
#
#   DESCRIPTION: 
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#                Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 11/21/2016 15:13:37
#      REVISION:  04/28/20
#
# Copyright 2014-2020 devops.center llc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#===============================================================================

#set -o nounset     # Treat unset variables as an error
set -o errexit      # exit immediately if command exits with a non-zero status
#set -x             # essentially debug mode

# Assumes that this is being installed on top of a dcStack web proto
# (supervisor, base-utils, python, etc)

# Create jenkins user and the new default directory.
sudo useradd jenkins

sudo mkdir -p /media/data/jenkins
sudo chown -R jenkins:jenkins /media/data/jenkins

sudo usermod -d /media/data/jenkins jenkins

# install java
sudo add-apt-repository ppa:openjdk-r/ppa -y
sudo apt update
sudo apt install openjdk-11-jdk
java -version

# install jenkins
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt -y install jenkins

mkdir /media/data/jenkins/.ssh
echo "JENKINS_HOME=/media/data/jenkins" | sudo tee -a /etc/default/jenkins
echo "AWS_KEYS=/media/data/jenkins/.ssh" | sudo tee -a /etc/default/jenkins

# copy the configs for running jenkins
sudo cp -a conf/program_jenkins.conf /etc/supervisor/conf.d/program_jenkins.conf
sudo cp -a conf/run_jenkins.sh /etc/supervisor/conf.d/run_jenkins.sh
sudo cp -a conf/run_jenkins-no_https.sh /etc/supervisor/conf.d/run_jenkins-no_https

#-------------------------------------------------------------------------------
# set up a nightly jenkins backup
#-------------------------------------------------------------------------------
theHostName=$(hostname)
if ! (crontab -l |grep '^[^#].*jenkins-backup.sh\b.*'); then
cat << EOF | crontab -
MAILTO=""
PATH=/usr/local/opt/python/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

11 03  *   *   *     /home/ubuntu/dcStack/buildtools/jenkins/jenkins-backup.sh ${theHostName}
EOF
fi

# install grunt-cli
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g grunt-cli

# prevent services from starting automatically after package install
# stop the systemd jenkins so that it can be disabled and removed
sudo service jenkins stop

#disable init.d autostart
sudo update-rc.d jenkins disable

# start/restart supervisor to start jenkins
sudo /etc/init.d/supervisor restart

