#!/bin/bash -e

# prevent services from starting automatically after package install
echo -e '#!/bin/bash\nexit 101' | sudo tee /usr/sbin/policy-rc.d
sudo chmod +x /usr/sbin/policy-rc.d

cd dcStack

# install dependencies
./buildtools/utils/base-utils.sh
sudo add-apt-repository -y "deb http://gb.archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
sudo apt-get update
sudo apt-get -y install build-essential libssl-dev libffi-dev python-dev fontconfig python-software-properties software-properties-common

# install pip directly, distro version is broken
curl https://bootstrap.pypa.io/get-pip.py | sudo python
sudo ln -s /usr/local/bin/pip /usr/bin/pip

sudo pip install fabric==1.10.2 paramiko pyasn1 cryptography idna setuptools enum34 ipaddress cffi pycparser gitpython ecdsa pycrypto s3cmd

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

# install supervisor to manage jenkins
./buildtools/utils/install-supervisor.sh

sudo cp -a buildtools/jenkins/program_jenkins.conf /etc/supervisor/conf.d/program_jenkins.conf
sudo cp -a buildtools/jenkins/run_jenkins.sh /etc/supervisor/conf.d/run_jenkins.sh

# install grunt-cli
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g grunt-cli

# start/restart supervisor to start jenkins
sudo /etc/init.d/supervisor restart
