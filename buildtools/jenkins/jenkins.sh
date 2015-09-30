#!/bin/bash -evx

sudo apt-get -qq update && apt-get -qq -y install python-software-properties software-properties-common && \
        sudo add-apt-repository -y "deb http://gb.archive.ubuntu.com/ubuntu $(lsb_release -sc) universe" && \
            sudo apt-get -qq update

sudo add-apt-repository ppa:saiarcot895/myppa && \
        sudo apt-get -qq update && \
            sudo apt-get -qq -y install apt-fast

sudo apt-fast -qq update
sudo apt-fast -qq -y install wget sudo vim curl build-essential fontconfig

wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-fast -qq update
sudo apt-fast -qq -y install jenkins

#echo "JENKINS_HOME=/media/data/jenkins" | sudo tee -a /etc/environment
echo "JENKINS_HOME=/media/data/jenkins" | sudo tee -a /etc/default/jenkins

sudo mkdir -p /media/data/jenkins
sudo chown -R jenkins:jenkins /media/data/jenkins
