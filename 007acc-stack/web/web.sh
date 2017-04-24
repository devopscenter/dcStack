#!/bin/bash -e

#
# App-specific web install for 007ACC
#

source /usr/local/bin/dcEnv.sh                       # initalize logging environment
dcStartLog "install of app-specific web for 007acc"


sudo pip install -r requirements.txt

curl -sL https://deb.nodesource.com/setup_4.x | sudo bash -

sudo apt-get install -y nodejs

sudo apt-get install -y build-essential 

curl -L https://npmjs.com/install.sh | sudo sh

sudo npm install -g less

sudo npm install -g coffee-script

dcEndLog "install of app-specific web for 007acc"
